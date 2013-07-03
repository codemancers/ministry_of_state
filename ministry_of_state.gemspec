# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ministry_of_state/version'

Gem::Specification.new do |spec|
  spec.name          = "ministry_of_state"
  spec.version       = MinistryOfState::VERSION

  spec.authors       = ["Hemant Kumar"]
  spec.email         = ["gethemant@gmail.com"]
  spec.description   = %q{A ActiveRecord plugin for working with state machines}
  spec.summary       = %q{Handling state machines}
  spec.homepage      = %q{http://github.com/gnufied/ministry_of_state}

  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.has_rdoc      = true
  spec.extra_rdoc_files = ["LICENSE.txt",
                           "README.rdoc"]
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency             "rails", "~> 3.2.13"
  # spec.add_development_dependency "sqlite3", "~> 1.3.7"
  spec.add_development_dependency "pg", "~> 0.15.1"
  spec.add_development_dependency "shoulda", "~> 3.5.0"
  spec.add_development_dependency "mocha", "~> 0.14.0"
  spec.add_development_dependency "debugger", "~> 1.6.0"
end
