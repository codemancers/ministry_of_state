class Article < ActiveRecord::Base
  include MinistryOfState 
  ministry_of_state(:initial_state => 'pending', :state_column => 'status' )
end
