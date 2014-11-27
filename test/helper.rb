require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'minitest/autorun'
require 'minitest/unit'
require 'shoulda'

# TODO: Fix this one when shoulda-context patches MiniTest::Unit::TestCase
if defined?(MiniTest::Unit::TestCase)
  MiniTest::Unit::TestCase.class_eval { include ShouldaContextLoadable }
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ministry_of_state'

