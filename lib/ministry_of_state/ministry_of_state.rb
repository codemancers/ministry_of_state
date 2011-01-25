module MinistryOfState

  def self.included(base)
    base.extend MinistryOfState::ClassMethods
  end

  module ClassMethods

    def ministry_of_state(opts={})
      class_attribute :states
      class_attribute :events

      class_attribute :initial_state
      class_attribute :state_column

      raise 'should define initial state' unless opts[:initial_state]

      self.initial_state = opts[:initial_state]
      self.state_column  = opts[:state_column] || 'status'
      self.states        = HashWithIndifferentAccess.new
      self.events        = HashWithIndifferentAccess.new

      add_state(self.initial_state)
      self.send(:include, MinistryOfState::InstanceMethods)

      before_create :set_initial_state
      after_create :run_initial_state_actions
    end

    def add_state(name, options={})
      self.states.merge!(name => options)
      define_method("#{name.to_s}?") { check_state(name) }
    end

    def add_event(name, &block)
      opts = class_eval(&block)
      self.events.merge!(name => opts)
      define_method("#{name.to_s}!") { fire(name) }
    end

    def transitions(opts={})
      raise 'specify from and to options' if opts[:from].blank? || opts[:to].blank?
      opts[:from] = [opts[:from]] unless opts[:from].is_a?(Array)
      {:from => opts[:from], :to => opts[:to], :guard => opts[:guard]}
    end

  end

  module InstanceMethods

    def set_initial_state
      begin
        enter   = self.class.states[self.class.initial_state][:enter]
        transaction do
          call(enter) if enter
        end
        true
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
      write_attribute self.class.state_column, self.class.initial_state
    end

    def run_initial_state_actions
      begin
        after   = self.class.states[self.class.initial_state][:after]
        transaction do
          call(after) if after
        end
        true
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
    end

    def check_state(state)
      send(self.class.state_column) == state.to_s
    end

    def fire(event)
      events      = self.class.events
      states      = self.class.states
      options     = events[event]
      to_state    = options[:to]
      check_guard = options[:guard] ? call(options[:guard]) : true
      return unless check_guard
      begin
        transaction do
          enter = states[to_state][:enter]
          after = states[to_state][:after]
          exit  = states[to_state][:exit]

          call(enter) if enter
          current_state = send(self.class.state_column)
          check_transitions?(current_state, options)
          attributes[self.class.state_column] = to_state.to_s
          save!
          call(exit) if exit
          call(after) if after
        end
        true
      rescue StandardError => e
        errors.add(:base, e.to_s)
        false
      end
    end

    def check_transitions?(current_state, opts)
      raise "event not allowed from '#{current_state}' state" unless opts[:from].include?(current_state)
    end

    def call(callback)
      callback.is_a?(Proc) ? callback.call(self) : send(callback)
    end

  end


end