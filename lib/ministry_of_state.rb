module MinistryOfState
  unless MinistryOfState.const_defined?(:VERSION)
    VERSION = "0.0.2"
  end
  require "ministry_of_state/railtie"
end
