module MinistryOfState
  extend ActiveSupport::Concern

  class InvalidState < StandardError; end
  class NoInitialState < StandardError; end
  class TransitionNotAllowed < StandardError; end
  class InvalidStateColumn < StandardError; end

  class MosState
    def initialize(name, column, opts)
      @name, @column, @opts = name, column, opts
    end

    attr_reader :name, :column, :opts

    def initial?
      opts[:initial]
    end
  end

  class MosEvent
    def initialize(name, column, opts)
      @name, @column, @opts = name, column, opts
    end

    attr_reader :name, :column, :opts
  end

  module ClassMethods

    # create a hash for states
    def prepare_mos_attributes
      unless self.respond_to?(:states)
        class_attribute :states
        class_attribute :events

        self.states = HashWithIndifferentAccess.new
        self.events = HashWithIndifferentAccess.new

        before_create :set_initial_states
        after_create  :run_initial_state_actions
      end
    end

    def get_initial_state_for(column)
      self.states.each do |name, state|
        return state if column == state.column && state.initial?
      end
      nil
    end

    def ministry_of_state(column)
      prepare_mos_attributes
      @mos_current_column_ = column
      yield

      initial_state = get_initial_state_for(column)
      raise NoInitialState.new("You need to specify initial state") unless initial_state
    end

    def add_initial_state(name)
      add_state(name, :initial => true)
    end

    def add_state(name, options={})
      state = MosState.new(name.to_s, @mos_current_column_, options)
      self.states.merge!(name.to_s => state)
      class_eval <<-RUBY,__FILE__,__LINE__+1
        def #{name.to_s}?; check_state('#{name}'); end
      RUBY
    end

    def add_event(name, options = {},&block)
      opts = class_eval(&block)
      event = MosEvent.new(name.to_s, @mos_current_column_, opts)
      self.events.merge!(name.to_s => event)
      class_eval <<-RUBY,__FILE__,__LINE__+1
        def #{name.to_s}!
          fire('#{name}')
        end
      RUBY
    end

    def transitions(opts = {})
      if opts[:from].blank? || opts[:to].blank?
        raise TransitionNotAllowed.new("You need to specify from and to states")
      end
      opts[:from] = Array(opts[:from]).map(&:to_sym)
      {:from => opts[:from], :to => opts[:to], :guard => opts[:guard] }
    end
  end

  def set_initial_states
    states.each do |name, state|
      next unless state.initial?

      begin
        enter = state.opts[:enter]
        invoke_callback(enter) if enter
        true
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
      default_state = read_attribute( state_machine_column(state.column) )
      write_attribute(state_machine_column(state.column), state.name) unless default_state
    end
  end

  def run_initial_state_actions
    states.each do |name, state|
      next unless state.initial?

      begin
        after = state.opts[:after]
        invoke_callback(enter) if after
        true
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
    end
  end

  def current_state(column)
    send("#{column}_was").to_sym
  end

  def check_state(state)
    column = states[state].column
    send("#{column}_was") == state.to_s
  end

  def fire(event)
    options   = events[event].opts
    to_state  = options[:to]
    column    = events[event].column

    raise TransitionNotAllowed.new("Invalid 'to' state '#{to_state}'") unless states[to_state]
    check_guard = options[:guard] ? invoke_callback(options[:guard]) : true
    return unless check_guard
    enter = states[to_state].opts[:enter]
    after = states[to_state].opts[:after]
    exit  = states[to_state].opts[:exit]
    invoke_callback(enter) if enter

    begin
      transaction do
        self.lock!
        t_current_state = send( state_machine_column(column) ).try(:to_sym)
        check_transitions?(t_current_state, options)
        write_attribute( state_machine_column(column), to_state.to_s )
        save
      end

      invoke_callback(exit) if exit
      invoke_callback(after) if after
      self.errors.empty?
    rescue StandardError => e
      errors.add(:base, e.to_s)
      false
    end
  end

  def state_machine_column(column)
    if(self.class.column_names.include?(column))
      column
    else
      raise InvalidStateColumn.new("State column '#{column}' does not exist in table '#{self.class.table_name}'")
    end
  end

  def check_transitions?(t_current_state, opts)
    unless opts[:from].include?(t_current_state)
      raise InvalidState.new("Invalid from state '#{t_current_state}' for target state '#{opts[:to]}'")
    end
  end

  def invoke_callback(callback)
    callback.is_a?(Proc) ? callback.call(self) : send(callback)
  end
end
