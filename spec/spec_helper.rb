require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'rspec'
#require 'rspec/interop/test'
require 'rack/test'

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.join(File.dirname(__FILE__), '../application')
#require_relative 'application'

# TODO: Replace this with mongoid.
# establish in-memory database for testing
DataMapper.setup(:default, "sqlite3::memory:")

Rspec.configure do |c|
  c.before(:each) { DataMapper.auto_migrate! }
  #c.mock_with :rspec
end
