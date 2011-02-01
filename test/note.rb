class Note < ActiveRecord::Base
  include MinistryOfState
  ministry_of_state(:state_column => 'status' )
end
