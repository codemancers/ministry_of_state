class Blog < ActiveRecord::Base

   ministry_of_state(:initial_state => 'pending', :state_column => 'status' )
   attr_accessor :foo
   add_state :approved, :enter => :test_method

   add_event :approve do
     transitions :from => 'pending', :to => 'approved'
   end

  def test_method
    @foo = true
  end

end
