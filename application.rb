require 'rubygems'
require "bundler/setup"
require 'sinatra'
require 'json'
require_relative 'environment'


configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  set :root, File.dirname(__FILE__)
end

error do
  e = request.env['sinatra.error']
  cache_control :no_cache
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end
# Let's set a default cache-control header for all requests

before do
  cache_control :public
end

helpers do
  # add your helpers here
end
get '/news' do
  haml :news
end
get '/contact' do
  haml :contact
end
get '/testing' do
  flash.now[:info] = "Hello, I'm testing!"
  haml :testing
end
get '/testing2' do
  cache_control :public, :max_age => 360
 # last_modified (Time.now - 1.day).httpdate
  'hello world'
end
post '/upload' do
  # Save files
  @replay = Replay.new
  begin
    @replay.original = params[:file]
    if params[:mapfile] then
      @replay.map = params[:mapfile]
    end
  rescue CarrierWave::IntegrityError
    puts "That is not a savegame or map file silly!"
  end
  @replay.description = params[:description]
  if not @replay.save then
    flash.next[:error] =  "Something went wrong with saving the record: #{@replay.errors}"
    redirect '/'
  end
  # Hand replay off to resque.
  @replay.async_parse
  # Redirect the user to where the replay will appear.
  # TODO: Make a nice ajax loading thingy instead.
  flash.next[:info] = 'Replay added successfully, parsing now!'
  redirect "/replay/#{@replay.id}"
end
get '/stats' do
  cache_control :public, :must_revalidate, :max_age => 360
  @replay_count = Replay.all.count
  last_modified Replay.all.first.updated_at
  etag @replay_count
  @parse_success = Replay.all(:conditions => {:generated => true}).count
  @parse_failure = Replay.all(:conditions => {:generated => false}).count
  haml :stats
end
get '/g/:id' do
  @replay = Replay.find(params[:id])
  content_type :json
  {:generated => @replay.generated}.to_json
end
get '/replay/:id' do
  @replay = Replay.find(params[:id])
  unless @replay then halt 404, "No such replay" end
  if @replay.generated then
    cache_control :public, :must_revalidate, :max_age => 3600
  else
    # This is to prevent caching of a error message when it hasn't been processed yet :-)
    cache_control :public, :must_revalidate, :max_age => 0
   end
  haml :replay
end
# Pagination currently setup but no next/previous actions in the view.
get '/replays' do
  cache_control :public, :must_revalidate, :max_age => 360
  @replays = Replay.where(:generated => true).order_by(:_id.desc).paginate :page => 1, :per_page => 25
  last_modified @replays.first.updated_at
  haml :replays
end
get '/failed' do
  cache_control :public, :must_revalidate, :max_age => 360
  @replays = Replay.where(:generated => false).order_by(:_id.desc).paginate :page => 1, :per_page => 25
  haml :replays # reusable views, woo!
end
get '/replays/:page' do
  cache_control :public, :must_revalidate, :max_age => 360
  @replays = Replay.where(:generated => true).order_by(:_id.desc).paginate :page => params[:page], :per_page => 25
  haml :replays
end
get '/' do
  cache_control :public, :must_revalidate, :max_age => 15.minutes
  haml :index
end
# Health check for varnish, makes us happy!
get '/health' do
  cache_control :public, :must_revalidate, :max_age => 3600
  halt 200, 'OK'
end
