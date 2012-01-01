# http://unicorn.bogomips.org/SIGNALS.html

rack_env = ENV['RACK_ENV'] || 'production'
app_root = "/home/civ5replays/civ5replays/"

God.watch do |w|
  w.name = "unicorn"
  w.interval = 30.seconds # default

  # unicorn needs to be run from the rails root
  w.start = "cd #{app_root} && bundle exec unicorn -c #{app_root}/config/unicorn.rb -E #{rack_env} -D"

  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat #{app_root}/tmp/pids/unicorn.pid`"

  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat #{app_root}/tmp/pids/unicorn.pid`"

  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "#{app_root}/tmp/pids/unicorn.pid"

  w.uid = 'civ5replays'
  w.gid = 'civ5replays'

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
