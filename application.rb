require 'rubygems'
require "bundler/setup"
require 'sinatra'
require_relative 'environment'
require_relative 'workers/job'
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
post '/upload' do
  redirect '/', :error => "File seems to be empty" unless params[:file][:tempfile].size > 0
  @resource = Resource.new(:file => make_paperclip_mash(params[:file]))
  redirect '/', :error => "There were some errors processing your request...\n#{@resource.errors.inspect}" unless @resource.save
  @resource.async_generate_replay
  
  haml :processing

end
get '/upload' do
  redirect '/', :notice => "Upload something!"
end
get '/' do
  haml :index
end
