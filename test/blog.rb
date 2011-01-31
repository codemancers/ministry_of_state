class Blog < ActiveRecord::Base

   ministry_of_state(:initial_state => 'pending', :state_column => 'status' )

   add_state :approved, :enter => :test_method

   add_event :approve do
     transitions :from => 'pending', :to => 'approved'
   end

  def test_method
    return true
  end

end
