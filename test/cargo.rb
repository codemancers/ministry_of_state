class Cargo < ActiveRecord::Base
  include MinistryOfState

  ministry_of_state('payment') do
    add_initial_state 'unpaid'
    add_state :paid

    add_event(:pay) do
      transitions(:from => :unpaid, :to => :paid)
    end
  end

  ministry_of_state('shippment') do
    add_initial_state 'unshipped'
    add_state :shipped
    add_state :delivered

    add_event(:bill_paid) do
      transitions(:from => :unshipped, :to => :shipped)
    end

    add_event(:cargo_delivered) do
      transitions(:from => :shipped, :to => :delivered)
    end
  end
end
