class User < ActiveRecord::Base
  include MinistryOfState
  validates_presence_of :gender, :on => :update, :if => :allow_gender_validation
  validates_presence_of :firstname, :lastname

  ministry_of_state(:initial_state => 'pending', :state_column => 'status' )
  add_state :active
  add_state :pending_payment
  
  add_event(:activate) do
    transitions(:from => :pending, :to => :active)
  end

  add_event(:pending_payment) do
    transitions(:from => :active, :to => :pending_payment)
  end

  add_event(:foobar) do
    transitions(:from => :pending, :to => :foobar)
  end
  
  def allow_gender_validation
    !pending?
  end
end
