require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'test/unit/rr'
require 'yaml'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fluent/test'
require 'fluent/input'
require 'fluent/log'
require 'fluent/test/driver/input'
require 'fluent/plugin/in_mysql_appender'
require 'fluent/plugin/in_mysql_appender_multi'

class Test::Unit::TestCase
end
