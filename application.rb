require 'rubygems'
require "bundler/setup"
require 'sinatra'
require_relative 'environment'

def make_paperclip_mash(file_hash)
  mash = Mash.new
  mash['tempfile'] = file_hash[:tempfile]
  mash['filename'] = file_hash[:filename]
  mash['content_type'] = file_hash[:type]
  mash['size'] = file_hash[:tempfile].size
  mash
end

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
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
  rescue CarrierWave::IntegrityError
    puts "wrong file silly"
  end
  @replay.description = params[:description]
  p @replay.errors.full_messages
  redirect '/', :error => "Something went wrong with saving the record: #{@replay.errors.inspect}" unless @replay.save
  @replay.async_parse
  #@resource.async_generate_replay
  redirect "/replay/#{@replay.id}"

end
get '/replay/:id' do
  @replay = Replay.get(params[:id])
  haml :replay
end
get '/' do
  haml :index
end
