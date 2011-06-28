class Article < ActiveRecord::Base
  include MinistryOfState

  ministry_of_state('status') do
    add_initial_state 'pending'
  end

end
