module MinistryOfState

  def self.included(base)
    base.extend MinistryOfState::ClassMethods
  end

  module ClassMethods

    def state_column(column=nil)

    end

    def initial_state(set_state=nil)

    end

    def add_state(state, options={})

    end

    def add_event(name, &block)

    end
    
  end

  module InstanceMethods

    def test

    end

  end

end