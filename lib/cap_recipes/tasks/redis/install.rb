# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :redis do
    roles[:redis] #make an empty role
    set :redis_ver, 'redis-2.0.4'
    set :redis_src, "http://redis.googlecode.com/files/redis-2.0.4.tar.gz"
    set :redis_path, "/opt/redis"
    set :redis_bind, nil # ie: 127.0.0.1 will bind to a specific address otherwise all interfaces
    set :redis_port, '6379'
    set :redis_timeout, '300'
    set :redis_init_path, File.join(File.dirname(__FILE__),'redis.init')
    set :redis_conf_path, File.join(File.dirname(__FILE__),'redis.conf')
    
    #TODO build option to enable building with tcmalloc https://github.com/antirez/redis

    #Trying to create a Consistent DSL
    # :install is all about making a startable basic service/function; getting code on the box, compiling, start scripts etc.
    # :setup is all about pushing the system level config files that will make the service operate the way we want.
    #        We abstract it this way, so that when making  changes to the setup files it doesn't require calling the install tasks,
    #        which may either take longer, be unnecessary or could potentially be destructive.
    # :configure is all about pushing application level config files

    desc "install redis-server"
    task :install, :roles => :redis do
      utilities.apt_install %w[build-essential wget]
      utilities.addgroup "redis", :system => true
      utilities.adduser "redis" , :nohome => true, :group => "redis", :system => true, :disabled_login => true
      utilities.sudo_upload_template redis_init_path, "/etc/init.d/redis", :mode => "+x", :owner => 'root:root'
      
      sudo "mkdir -p #{redis_path}"
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{redis_src} && #{sudo} tar xzf #{redis_ver}.tar.gz"
      run "cd /usr/local/src/#{redis_ver} && #{sudo} make"
      sudo "/etc/init.d/redis stop;true" #If this is a re-install need to stop redis      
      run "cd /usr/local/src/#{redis_ver} && #{sudo} cp redis-server redis-benchmark redis-cli redis-check-dump redis-check-aof #{redis_path}"
      sudo "cp /usr/local/src/#{redis_ver}/redis.conf #{redis_path}/redis.conf.original"
      sudo "touch /var/log/redis.log"
      sudo "chown redis:redis /var/log/redis.log"
      setup
      sudo "chown -R redis:redis #{redis_path}"
      sudo "update-rc.d -f redis defaults"
      start
    end

    desc "setup redis-server"
    task :setup, :roles => :redis do
      utilities.sudo_upload_template redis_conf_path, "#{redis_path}/redis.conf", :owner => "redis:redis"
    end
  end
end