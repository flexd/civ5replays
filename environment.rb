require 'rubygems'
require "bundler/setup"
require 'haml'
require 'ostruct'
require 'rack-flash'
require 'sinatra' unless defined?(Sinatra)
require 'mongoid'
require 'sinatra/redirect_with_flash'
require 'resque'
require 'carrierwave'
require 'pp'
#require 'carrierwave/orm/datamapper'

APP_ROOT = File.expand_path(File.dirname(__FILE__))
#TODO: Temp fix for static caching with varnish, until rack #157 is fixed.
require 'sinatra/cookie_thief'

configure do
  
  #use Sinatra::CookieThief
  SiteConfig = OpenStruct.new(
                 :title => 'Civilization 5 replay generator',
                 :author => 'flexd',
                 :url_base => 'http://civ5.flexd.net/',
                 :db_name => 'civ5replays'
               )
  #set :mongo_host, "192.168.30.23"
  #set :mongo_db, "#{SiteConfig.db_name}_production" #{Sinatra::Base.environment}
  # load the database settings
  Mongoid.load!("config/mongoid.yml") 
 
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
  use Rack::Session::Cookie, :key => 'app.session', :path => '/', :expire_after => 2592000, :secret => 'JZ6ciUo4GHkYu1nc0Z90uW9anPlqt7lC8bHCkaIzlldlpuuoVcFSFNjhCbJM8S0'
  #use Rack::Session::Pool, :expire_after => 2592000
  use Rack::Flash
#  enable :sessions  
end
