module MinistryOfState
  extend ActiveSupport::Concern


  class InvalidState < Exception; end

  class NoInitialState < Exception; end

  class TransitionNotAllowed < Exception; end
  class InvalidStateColumn < Exception; end
  
  module ClassMethods
    def ministry_of_state(opts = {})
      class_attribute :states
      class_attribute :events

      class_attribute :initial_state
      class_attribute :state_column

      raise NoInitialState.new("You need to specify initial state") unless opts[:initial_state]

      self.initial_state = opts[:initial_state]
      self.state_column  = opts[:state_column] || 'status'
      self.states        = HashWithIndifferentAccess.new
      self.events        = HashWithIndifferentAccess.new

      add_state(self.initial_state)
      before_create :set_initial_state
      after_create :run_initial_state_actions
    end

    def add_state(name, options={})
      self.states.merge!(name => options)
      class_eval <<-RUBY,__FILE__,__LINE__+1
        def #{name}?; check_state('#{name}'); end
      RUBY
    end

    def add_event(name, &block)
      opts = class_eval(&block)
      self.events.merge!(name => opts)
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

  module InstanceMethods
    
    def set_initial_state
      begin
        enter   = states[initial_state][:enter]
        invoke_callback(enter) if enter
        true
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
      write_attribute state_machine_column, initial_state
    end

    def run_initial_state_actions
      begin
        after = states[initial_state][:after]
        invoke_callback(after) if after
        true
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
    end

    def check_state(state)
      send("#{state_machine_column}_was") == state.to_s
    end

    def fire(event)
      options     = events[event]
      to_state    = options[:to]
      raise TransitionNotAllowed.new("Invalid 'to' state '#{to_state}'") unless states[to_state]
      check_guard = options[:guard] ? invoke_callback(options[:guard]) : true
      return unless check_guard
      begin
        transaction do
          enter = states[to_state][:enter]
          after = states[to_state][:after]
          exit  = states[to_state][:exit]

          invoke_callback(enter) if enter
          self.lock!
          current_state = send(state_machine_column).try(:to_sym)
          check_transitions?(current_state, options)
          write_attribute(state_machine_column,to_state.to_s)
          save
          invoke_callback(exit) if exit
          invoke_callback(after) if after
        end
        self.errors.empty?
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
    end

    def state_machine_column
      if(self.class.column_names.include?(state_column))
        state_column
      else
        raise InvalidStateColumn.new("State column '#{state_column}' does not exist in table '#{self.class.table_name}'")
      end
    end
    
    def check_transitions?(current_state, opts)
      unless opts[:from].include?(current_state)
        raise InvalidState.new("Invalid from state '#{current_state}' for target state '#{opts[:to]}'")
      end
    end

    def invoke_callback(callback)
      callback.is_a?(Proc) ? callback.call(self) : send(callback)
    end
  end
end
