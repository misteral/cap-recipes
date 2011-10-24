# http://unicorn.bogomips.org/SIGNALS.html

God.watch do |w|
  w.name = "nginx_passenger"
  w.group = "nginx"
  w.interval = 10.seconds

  w.start = "/etc/init.d/nginx_passenger start"
  w.stop = "/etc/init.d/nginx_passenger stop"
  w.restart = "/etc/init.d/nginx_passenger restart"

  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.pid_file = "<%=nginx_passenger_pid%>"

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
      c.notify = %w[ <%=god_notify_list%> ]
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 90.percent
      c.times = 5
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
