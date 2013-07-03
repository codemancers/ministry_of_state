class BlogWithExitCallback < ActiveRecord::Base
  self.table_name = 'blogs'
  
  include MinistryOfState
  ministry_of_state('status') do
    add_initial_state :pending, exit: :exit_pending
    add_state :active

    add_event(:activate) do
      transitions(from: :pending, :to => :active)
    end
  end

  def exit_pending
    # noop
  end
end
