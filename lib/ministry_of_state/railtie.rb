require "rails"
require "active_record"
require "active_support"
require "active_support/core_ext/class"
require File.dirname(__FILE__) + "/ministry_of_state"

module MinistryOfState
  class Ralitie < Rails::Railtie
    config.after_initialize do

    end
  end
  # instance methods
end

ActiveRecord::Base.send(:include, MinistryOfState)

