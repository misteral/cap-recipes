require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/../aptitude/manage')

Capistrano::Configuration.instance(true).load do

  namespace :redis do

    set :redis_ver, 'redis-2.0.4'
    set :redis_src, "http://redis.googlecode.com/files/redis-2.0.4.tar.gz"
    set :redis_path, "/opt/redis"
    set :redis_bind, nil # ie: 127.0.0.1 will bind to a specific address otherwise all interfaces
    set :redis_port, '6379'
    set :redis_timeout, '300'
    
    #TODO build option to enable building with tcmalloc https://github.com/antirez/redis

    desc "install redis-server"
    task :setup, :role => :db do
      utilities.apt_install %w[build-essential wget]
      utilities.addgroup "redis", :system => true
      utilities.adduser "redis" , :nohome => true, :group => "redis", :system => true, :disabled_login => true
      sudo "mkdir -p #{redis_path}"
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{redis_src} && #{sudo} tar xzf #{redis_ver}.tar.gz"
      run "cd /usr/local/src/#{redis_ver} && #{sudo} make"
      run "cd /usr/local/src/#{redis_ver} && #{sudo} cp redis-server redis-benchmark redis-cli redis-check-dump redis-check-aof #{redis_path}"
      sudo "cp /usr/local/src/#{redis_ver}/redis.conf #{redis_path}/redis.conf.original"
      utilities.sudo_upload_template "redis/redis.init", "/etc/init.d/redis", :mode => "+x", :owner => 'root:root'
      sudo "touch /var/log/redis.log"
      sudo "chown redis:redis /var/log/redis.log"
      utilities.sudo_upload_template "redis/redis.conf", "#{redis_path}/redis.conf"
      sudo "chown -R redis:redis #{redis_path}"
      sudo "update-rc.d -f redis defaults"
      start
    end
  end
end