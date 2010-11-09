require 'rubygems'
require "bundler/setup"
require 'sinatra'
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

BOWTIE_AUTH = {:user => 'admin', :pass => '12345' }

post '/upload' do
  @replay = Replay.new
  begin
    @replay.original = params[:file]
    if params[:mapfile] then
      @replay.map = params[:mapfile]
    end
  rescue CarrierWave::IntegrityError
    puts "wrong file silly"
  end
  @replay.description = params[:description]
  p @replay.errors.full_messages
  redirect '/', :error => "Something went wrong with saving the record: #{@replay.errors.inspect}" unless @replay.save
  @replay.async_parse
  redirect "/replay/#{@replay.id}"

end
get '/replay/:id' do
  @replay = Replay.find(params[:id])
  unless @replay then halt 404, "No such replay" end
  haml :replay
end
get '/replays' do
  @replays = Replay.all.paginate
  haml :replays
end
get '/replays/:page' do
  @replays = Replay.all.paginate(:page => params[:page])
  haml :replays
end
get '/' do
  haml :index
end
