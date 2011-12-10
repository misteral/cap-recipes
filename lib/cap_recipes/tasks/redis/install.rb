Capistrano::Configuration.instance(true).load do
  #redis primer http://jramirez.tumblr.com/post/2589232577/prime-time-redis-101-set-up
  #redis primer http://library.linode.com/databases/redis/ubuntu-10.04-lucid

  namespace :redis do
    roles[:redis] #make an empty role
    set :redis_ver, 'redis-2.2.11'
    set(:redis_src) {"http://redis.googlecode.com/files/#{redis_ver}.tar.gz"}
    set :redis_base_path, "/opt/redis"

    set :redis_default_name, 'redis'
    set :redis_default_bind, nil
    set :redis_default_port, 6379
    set :redis_default_timeout, '300'
    set :redis_default_conf_path, File.join(File.dirname(__FILE__),'redis.conf')
    set :redis_god_path, File.join(File.dirname(__FILE__),'redis.god')
    set :redis_watcher, nil
    set :redis_suppress_runner, false

    set(:redis_layout) {
      [{:path => redis_base_path }] #if there's only the default then use the root of the path.
    }

    set :redis_init_path, File.join(File.dirname(__FILE__),'redis.init')
    set :redis_logrotate_path, File.join(File.dirname(__FILE__),'redis.logrotate')
    set :redis_cli_helper_path, File.join(File.dirname(__FILE__),'redis-cli-config.sh')
    #  set(:redis_cli_cmd) {"#{redis_path}/bin/redis-cli#{" -h #{redis_bind}" if redis_bind}#{" -p #{redis_port}" if redis_port} "}

    desc "install redis-server"
    task :install, :roles => :redis do
      utilities.apt_install %w[build-essential wget]
      utilities.addgroup "redis", :system => true
      utilities.adduser "redis" , :nohome => true, :group => "redis", :system => true, :disabled_login => true
      sudo "mkdir -p #{redis_base_path}/bin #{redis_base_path}/src /var/run/redis /var/log/redis"
      run "cd #{redis_base_path}/src && #{sudo} wget --tries=2 -c --progress=bar:force #{redis_src} && #{sudo} tar xzf #{redis_ver}.tar.gz"
      run "cd #{redis_base_path}/src/#{redis_ver} && #{sudo} make"
      #sudo "/etc/init.d/#{redis_name} stop;true" #If this is a re-install need to stop redis
      run "cd #{redis_base_path}/src/#{redis_ver} && #{sudo} make PREFIX=#{redis_base_path} install"
      sudo "cp #{redis_base_path}/src/#{redis_ver}/redis.conf #{redis_base_path}/redis.conf.original"
      sudo "chown -R redis:redis #{redis_base_path} /var/run/redis /var/log/redis"
    end

    # desc "push a redis cli helper to read a config and launch the right cli"
    # task :cli_helper, :roles => :redis do
    #   utilities.sudo_upload_template redis_cli_helper_path, File.join(redis_base_path,"bin","redis-cli-config"), :mode => "+x", :owner => 'root:root'
    # end

    desc "select redis watcher"
    task :watcher do
      redis.send("watch_with_#{redis_watcher}".to_sym) unless redis_watcher.nil?
    end

    desc "Use GOD as redis's runner"
    task :watch_with_god do
      #This is a test pattern, and may not be the best way to handle diverging
      #maintenance tasks based on which watcher is used but here goes:
      #rejigger the maintenance tasks to use god when god is in play
      %w(start stop restart).each do |t|
        task t.to_sym, :roles => :app do
          god.cmd "#{t} redis" unless redis_suppress_runner
        end
      end
      after "god:setup", "redis:setup_god"
    end

    desc "setup god to watch redis"
    task :setup_god, :roles => :redis do
      with_layout do
        god.upload redis_god_path, "#{redis_name}.god"
      end
    end

    desc "push a redis logrotate config"
    task :logrotate, :roles => :redis do
      utilities.sudo_upload_template redis_logrotate_path, "/etc/logrotate.d/redis", :owner => 'root:root'
    end

    desc "setup redis-server"
    task :setup, :roles => :redis do
      with_layout do
        sudo "touch /var/log/#{redis_name}.log"
        sudo "mkdir -p #{redis_path}"
        sudo "chown redis:redis /var/log/#{redis_name}.log"
        sudo "chown -R redis:redis #{redis_path}"
        utilities.sudo_upload_template redis_init_path, "/etc/init.d/#{redis_name}", :mode => "+x", :owner => 'root:root'
        utilities.sudo_upload_template redis_conf_path, "#{redis_path}/#{redis_name}.conf", :owner => "redis:redis"
        sudo "update-rc.d -f #{redis_name} defaults"
      end
    end

    desc "verify the redis-server"
    task :verify, :roles => :redis do
      run "#{redis_base_path}/bin/redis-server -v"
    end

    %w(start stop restart).each do |t|
      desc "#{t.capitalize} redis server"
      task t.to_sym, :roles => :redis do
        with_layout do
          #Process won't start unless protected by nohup
          sudo "nohup /etc/init.d/#{redis_name} #{t} > /dev/null"
        end
      end
    end

    def with_layout
      redis_layout.each do |layout|
        set :redis_name,    layout[:name]        || redis_default_name
        set :redis_path,    layout[:path]        || "#{redis_base_path}/#{redis_name}"
        set :redis_bind,    layout[:bind]        || redis_default_bind
        set :redis_port,    layout[:port]        || redis_default_port
        set :redis_timeout, layout[:timeout]     || redis_default_timeout
        set :redis_conf_path, layout[:conf_path] || redis_default_conf_path
        yield layout if block_given?
      end
    end

  end
end