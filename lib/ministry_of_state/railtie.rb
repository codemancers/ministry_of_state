require "rails"
require "active_record"

module MinistryOfState
  class Ralitie < Rails::Railtie
  end

  def self.included(base)
    base.extend MinistryOfState::ClassMethods
    super
  end

  module ClassMethods

  end

  # instance methods

end


