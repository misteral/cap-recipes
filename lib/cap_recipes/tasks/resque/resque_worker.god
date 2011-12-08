rails_env = "<%=rails_env%>"
rails_root = "<%=resque_root%>"

God.watch do |w|
  w.group = "resque-workers"
  w.name = "<%=resque_name%>-worker"
  w.interval = 30.seconds # 30 default

  # unicorn needs to be run from the rails root
  w.start = "cd #{rails_root} && RAILS_ENV=#{rails_env} QUEUE='*' <%=base_ruby_path%>/bin/bundle exec rake resque:work"

  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.stop_signal = 'QUIT'
  w.stop_timeout = 5.minutes
  w.env = {'PIDFILE' => "#{rails_root}/tmp/pids/resque-worker.pid"}
  w.pid_file = "#{rails_root}/tmp/pids/resque-worker.pid"
  w.log = "#{rails_root}/log/resque-worker.log"

  w.uid = '<%=resque_user%>'
  w.gid = '<%=resque_group%>'

  # clean pid files before start if necessary
  w.behavior(:clean_pid_file)

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits) do |c|
      c.notify = %w[ <%=god_notify_list%> ]
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
      c.notify = %w[ <%=god_notify_list%> ]
    end
  end
end
