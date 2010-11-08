require 'rubygems'
require "bundler/setup"
#require 'dm-core'
#require 'dm-timestamps'
#require 'dm-validations'
#require 'dm-aggregates'
#require 'dm-migrations'
#require 'dm-paperclip'
require 'haml'
require 'ostruct'
require 'rack-flash'
require 'sinatra' unless defined?(Sinatra)
require 'sinatra/mongoid'
require 'sinatra/redirect_with_flash'
require 'resque'
require 'carrierwave'
#require 'carrierwave/orm/datamapper'

APP_ROOT = File.expand_path(File.dirname(__FILE__))
set :mongo_db, "civ5replays_#{Sinatra::Base.environment}"
configure do
  SiteConfig = OpenStruct.new(
                 :title => 'Civilization 5 replay generator',
                 :author => 'flexd',
                 :url_base => 'http://localhost:4567/'
               )

  # load workers
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/workers")
  Dir.glob("#{File.dirname(__FILE__)}/workers/*.rb") { |lib| require File.basename(lib, '.*') }
  # load uploaders
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/uploaders")
  Dir.glob("#{File.dirname(__FILE__)}/uploaders/*.rb") { |lib| require File.basename(lib, '.*') }
  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
  # If you want the logs displayed you have to do this before the call to setup
  #DataMapper::Logger.new($stdout, :debug)
  # This is not the real password sillys :-)
  #DataMapper.setup(:default, "postgres://civ5replays_production:buO!NiEr@10.0.0.5/civ5replays_#{Sinatra::Base.environment}")
  #DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db"))
  use Rack::Flash
  enable :sessions
  
end
