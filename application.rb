require 'rubygems'
require "bundler/setup"
require 'sinatra'
require 'json'
require_relative 'environment'


configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  set :root, File.dirname(__FILE__)
  set :cache_enabled, true
  set :cache_output_dir, Proc.new { File.join(root, 'tmp', 'cache') }
  set :cache_logging_level, :debug
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  # add your helpers here
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
  redirect '/', :error => "Something went wrong with saving the record: #{@replay.errors.inspect}" unless @replay.save
  # Hand replay off to resque.
  @replay.async_parse
  # Redirect the user to where the replay will appear.
  # TODO: Make a nice ajax loading thingy instead.
  redirect "/replay/#{@replay.id}"

end
get '/stats' do
  @replay_count = Replay.all.count
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
  haml :replay
end
# Pagination currently setup but no next/previous actions in the view.
get '/replays' do
  @replays = Replay.where(:generated => true).order_by(:_id.desc).paginate :page => 1, :per_page => 25
  haml :replays
end
get '/failed' do
  @replays = Replay.where(:generated => false).order_by(:_id.desc).paginate :page => 1, :per_page => 25
  haml :replays # reusable views, woo!
end
get '/replays/:page' do
  puts "page is: #{params[:page]}"
  @replays = Replay.where(:generated => true).order_by(:_id.desc).paginate :page => params[:page], :per_page => 25
  haml :replays
end
get '/' do
  haml :index
end
