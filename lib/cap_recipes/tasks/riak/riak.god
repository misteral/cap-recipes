God.watch do |w|
  w.name = '<%=riak_name%>'
  w.group = 'riaks'
  w.interval = 40.seconds #give it enough time to remediate before testing it again

  daemon = '<%="#{riak_root}/bin/riak"%>'

  w.start   = "#{daemon} start"
  w.stop    = "#{daemon} stop"

  w.start_grace = 10.seconds
  w.stop_grace = 10.seconds
  w.stop_timeout = 20.seconds
  w.restart_grace = 10.seconds

  w.log = "<%=%Q{#{riak_root}/log}%>/god.log"

  w.transition(:init, { true => :up, false => :start }) do |on|
   on.condition(:http_response_code) do |c|
      c.host = '<%=riak_listen%>'
      c.port = '<%=riak_http_port%>'
      c.path = '/ping'
      c.code_is = 200
    end
  end

  w.transition([:start, :restart], :up) do |on|
   on.condition(:http_response_code) do |c|
      c.host = '<%=riak_listen%>'
      c.port = '<%=riak_http_port%>'
      c.path = '/ping'
      c.code_is = 200
      c.notify = %w[ <%=god_notify_list%> ]
    end
  end

  w.transition(:up, :restart) do |on|
   on.condition(:http_response_code) do |c|
      c.host = '<%=riak_listen%>'
      c.port = '<%=riak_http_port%>'
      c.path = '/ping'
      c.code_is_not = 200
      c.notify = %w[ <%=god_notify_list%> ]
    end
  end

  w.transition(:up, :unmonitored) do |on|
    on.condition(:flapping){|c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
      c.notify = %w[ <%=god_notify_list%> ]
    }
  end
end
