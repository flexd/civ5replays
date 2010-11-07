require_relative 'environment'
set :run, false
set :environment, :production


require_relative 'application'
run Sinatra::Application
