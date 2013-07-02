class BlogWithCallback < ActiveRecord::Base
  self.table_name = 'blogs'
  
  include MinistryOfState
  ministry_of_state('status') do
    add_initial_state :pending
    add_state :active, during: :during_callback

    add_event(:activate, on_transition: :on_transition) do
      transitions(from: :pending, :to => :active)
    end
  end
  
  def during_callback
    raise "an expection to test if it is inside transaction"
  end
  
  def on_transition
    raise "an expection to test if it is inside transaction"
  end
end
