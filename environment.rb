require 'rubygems'
require "bundler/setup"
require 'haml'
require 'ostruct'
require 'sinatra' unless defined?(Sinatra)
require 'sinatra/flash'
require 'rack'
require 'mongoid'
#require 'sinatra/redirect_with_flash'
require 'resque'
require 'carrierwave'

APP_ROOT = File.expand_path(File.dirname(__FILE__))
#TODO: Temp fix for static caching with varnish, until rack #157 is fixed.
#require 'sinatra/cookie_thief'

configure do
  
  #register Sinatra::CookieThief
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
  enable :sessions
end

fail 'wrong Rack version' if Rack.release != '1.3'

module SmartSession
  append_features Rack::Session::Cookie

  def commit_session?(env, session, options)
    if super
      request = Rack::Request.new(env)
      request.cookies.include?(@key) or (session and !session.empty?)
    end
  end
end
