class Blog < ActiveRecord::Base
  include MinistryOfState
  validates_presence_of :text

  attr_accessor :foo

  ministry_of_state('status') do
    add_initial_state 'pending'

    add_state :approved, :enter => :test_method
    add_state :cancelled

    add_event :approve do
      transitions :from => 'pending', :to => 'approved'
    end

    add_event(:cancel) do
      transitions from: :any, to: 'cancelled'
    end
  end

  def test_method
    @foo = true
  end

end
