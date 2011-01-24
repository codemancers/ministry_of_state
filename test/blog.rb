class MinistryOfState::Blog < ActiveRecord::Base

   ministry_of_state(:initial_state => 'pending', :state_column => 'aa' )

   add_state :approved, :enter => :test_method

   add_event :set_approved do
     transitions :from => 'pending', :to => 'approved', :guard => proc{ | o |  o }
   end

  def test_method
    return true
  end

end
