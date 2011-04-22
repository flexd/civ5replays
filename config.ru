require File.expand_path("../environment.rb", __FILE__)
set :run, false
set :environment, :production

require File.expand_path("../application.rb", __FILE__)
run Sinatra::Application
