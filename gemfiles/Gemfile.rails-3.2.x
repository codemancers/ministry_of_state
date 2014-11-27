# -*- ruby -*-

source 'http://rubygems.org'

gemspec path: '..'
gem 'rails', '~> 3.2.13'

# rails 3.2.x depends on minitest 4.x, so i had to hardcode it.
# rails 4.x depends on minitest 5.x which is default now
gem 'minitest', '~> 4.7.5'
