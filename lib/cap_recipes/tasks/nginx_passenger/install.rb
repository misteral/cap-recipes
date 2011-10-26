# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

# This Nginx is targeted for the :app role meant to be acting as a front end
# to phusion passenger based application

Capistrano::Configuration.instance(true).load do

  namespace :nginx_passenger do

    set :nginx_passenger_ver, '3.0.9'
    set :nginx_passenger_nginx_src, "http://nginx.org/download/nginx-1.0.6.tar.gz"
    set(:nginx_passenger_nginx_ver) { nginx_passenger_nginx_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }
    set :nginx_passenger_root, '/opt/nginx_passenger'
    set(:nginx_passenger_nginx_source_dir) {"#{nginx_passenger_root}/src/#{nginx_passenger_nginx_ver}"}
    set(:nginx_passenger_nginx_patch_dir) {"#{nginx_passenger_root}/src"}
    set :nginx_passenger_log_dir, "/var/log/nginx_passenger"
    set(:nginx_passenger_bin) {"#{nginx_passenger_root}/sbin/nginx"}
    set :nginx_passenger_pid, "/var/run/nginx_passenger.pid"
    set :nginx_passenger_conf_path, File.join(File.dirname(__FILE__),'nginx.conf')
    set :nginx_passenger_init_d_path, File.join(File.dirname(__FILE__),'nginx_passenger.init')
    set :nginx_passenger_app_conf_path, File.join(File.dirname(__FILE__),'app.conf')
    set :nginx_passenger_god_path, File.join(File.dirname(__FILE__),'nginx_passenger.god')
    set :nginx_passenger_init_d, "nginx_passenger"
    set :nginx_passenger_port, '80'
    set :nginx_passenger_server_name, '_'
    set(:nginx_passenger_runner_user) { user }
    set(:nginx_passenger_runner_group) { user }
    set :nginx_passenger_watcher, nil
    set :nginx_passenger_suppress_runner, false
    set :nginx_passenger_stub_conf_path, File.join(File.dirname(__FILE__),'stub_status.conf')
    set(:nginx_passenger_extra_configure_flags) { "--with-http_gzip_static_module --with-http_stub_status_module --add-module=#{nginx_passenger_nginx_patch_dir}/nginx_syslog_patch" }

    desc "select watcher"
    task :watcher do
      nginx_passenger.send("watch_with_#{nginx_passenger_watcher}".to_sym) unless nginx_passenger_watcher.nil?
    end

    desc "Use GOD as nginx_passenger's runner"
    task :watch_with_god do
      #This is a test pattern, and may not be the best way to handle diverging
      #maintenance tasks based on which watcher is used but here goes:
      #rejigger the maintenance tasks to use god when god is in play
      %w(start stop restart).each do |t|
        task t.to_sym, :roles => :app do
          god.cmd "#{t} nginx_passenger" unless nginx_passenger_suppress_runner
        end
      end
      after "god:setup", "nginx_passenger:setup_god"
    end

    desc "setup god to watch unicorn"
    task :setup_god, :roles => :app do
      god.upload nginx_passenger_god_path, 'nginx_passenger.god'
    end

    desc 'Installs nginx_passenger'
    task :install, :roles => :app do
      puts 'Installing Nginx_Passenger'
      utilities.apt_install "libssl-dev zlib1g-dev libcurl4-openssl-dev"
      sudo "mkdir -p #{nginx_passenger_nginx_source_dir} #{nginx_passenger_log_dir}"
      run "cd #{nginx_passenger_root}/src && #{sudo} wget --tries=2 -c --progress=bar:force #{nginx_passenger_nginx_src} && #{sudo} tar zxvf #{nginx_passenger_nginx_ver}.tar.gz"
      utilities.git_clone_or_pull "git://github.com/yaoweibin/nginx_syslog_patch.git", "#{nginx_passenger_nginx_patch_dir}/nginx_syslog_patch"
      run "cd #{nginx_passenger_nginx_source_dir} && #{sudo} sh -c 'patch -p1 < #{nginx_passenger_nginx_patch_dir}/nginx_syslog_patch/syslog_#{nginx_passenger_nginx_ver.split('-').last}.patch'"
      utilities.gem_install "passenger", nginx_passenger_ver
      sudo "#{base_ruby_path}/bin/passenger-install-nginx-module --auto --prefix=#{nginx_passenger_root} --nginx-source-dir=#{nginx_passenger_nginx_source_dir} --extra-configure-flags='#{nginx_passenger_extra_configure_flags}'"
      setup
    end

    task :setup, :roles => :app do
      sudo "mkdir -p #{nginx_passenger_root}/conf/sites-available #{nginx_passenger_root}/conf/sites-enabled"
      utilities.sudo_upload_template nginx_passenger_stub_conf_path,"#{nginx_passenger_root}/conf/sites-available/stub_status.conf"
      sudo "ln -sf #{nginx_passenger_root}/conf/sites-available/stub_status.conf #{nginx_passenger_root}/conf/sites-enabled/stub_status.conf"
      utilities.sudo_upload_template nginx_passenger_conf_path, "#{nginx_passenger_root}/conf/nginx.conf"
      utilities.sudo_upload_template nginx_passenger_init_d_path,"/etc/init.d/#{nginx_passenger_init_d}", :mode => "u+x"
    end
    
    desc "Write the application conf"
    task :configure, :roles => :app do
      utilities.sudo_upload_template nginx_passenger_app_conf_path, "#{nginx_passenger_root}/conf/sites-available/#{application}.conf"
      enable
    end

    desc "Enable the application conf"
    task :enable, :roles => :app do
      sudo "ln -sf #{nginx_passenger_root}/conf/sites-available/#{application}.conf #{nginx_passenger_root}/conf/sites-enabled/#{application}.conf"
    end

    desc "Disable the application conf"
    task :disable, :roles => :app do
      sudo "rm #{nginx_passenger_root}/conf/sites-enabled/#{application}.conf"
    end
    
    desc "Nginx Passenger Reopen"
    task :reopen, :roles => :app do
      sudo "#{nginx_passenger_root}/sbin/nginx -s reopen;true"
    end

    %w(start stop restart).each do |t|
      desc "#{t} nginx_passenger"
      task t.to_sym, :roles => :app do
        sudo "/etc/init.d/#{nginx_passenger_init_d} #{t}"
      end
    end
    
    namespace :passenger do
      desc "restart passenger application"
      task :restart, :roles => :app do
        run "touch #{latest_release}/tmp/restart.txt"
      end
    end

  end
end
