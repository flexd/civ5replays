# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example
@dir = "/home/kristoffer/civ5replays/"

worker_processes 2
working_directory @dir

preload_app true

timeout 30

# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later

listen "#{@dir}tmp/sockets/unicorn.sock", :backlog => 64
listen 8081, :tcp_nopush => true

# Set process id path
pid "#{@dir}tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log" 
