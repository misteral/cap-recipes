# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

# This Nginx is targeted for the :app role meant to be acting as a front end 
# to a unicorn based application

Capistrano::Configuration.instance(true).load do

  namespace :nginx_unicorn do

    set :nginx_unicorn_root, "/etc/nginx"
    set :nginx_unicorn_conf_path, File.join(File.dirname(__FILE__),'nginx.conf')
    set :nginx_unicorn_init_d_path, File.join(File.dirname(__FILE__),'nginx.init')
    set :nginx_unicorn_stub_conf_path, File.join(File.dirname(__FILE__),'stub_status.conf')
    set :nginx_unicorn_god_path, File.join(File.dirname(__FILE__),'nginx_unicorn.god')
    set :nginx_unicorn_init_d, "nginx"
    set :nginx_unicorn_runner, :init
    set :nginx_unicorn_suppress_runner, false
    set(:nginx_unicorn_upstream_socket){"#{shared_path}/sockets/unicorn.sock"}
    set :nginx_unicorn_watcher, nil
    set :nginx_unicorn_suppress_runner, false
    set :nginx_unicorn_port, '80'
    set :nginx_unicorn_server_name, 'localhost'
    set :nginx_unicorn_app_conf_path, File.join(File.dirname(__FILE__),'app.conf')

    desc "select watcher"
    task :watcher do
      nginx_unicorn.send("watch_with_#{nginx_unicorn_watcher}".to_sym) unless nginx_unicorn_watcher.nil?
    end

    desc "Use GOD as unicorn's runner"
    task :watch_with_god do
      #rejigger the maintenance tasks to use god when god is in play
      %w(start stop restart).each do |t|
        task t.to_sym, :roles => :app do
          god.cmd "#{t} unicorn" unless nginx_unicorn_suppress_runner
        end
      end
      after "god:setup", "nginx_unicorn:setup_god"
    end

    desc "setup god to watch unicorn"
    task :setup_god, :roles => :app do
      god.upload nginx_unicorn_god_path, 'nginx_unicorn.god'
    end

    desc 'Installs nginx for unicorn'
    task :install, :roles => :app do
      utilities.apt_install "libssl-dev zlib1g-dev libcurl4-openssl-dev nginx"
      setup
    end

    task :setup, :roles => :app do
      sudo "mkdir -p #{nginx_unicorn_root}/sites-available #{nginx_unicorn_root}/sites-enabled #{nginx_unicorn_root}/conf.d"
      utilities.sudo_upload_template nginx_unicorn_conf_path,"#{nginx_unicorn_root}/nginx.conf"
      utilities.sudo_upload_template nginx_unicorn_stub_conf_path,"#{nginx_unicorn_root}/conf.d/stub_status.conf"
      utilities.sudo_upload_template nginx_unicorn_init_d_path,"/etc/init.d/#{nginx_unicorn_init_d}", :mode => "u+x"
    end

    desc "Nginx Unicorn Reload"
    task :reload, :roles => :app do
      sudo "/etc/init.d/nginx reload"
    end

    desc "Nginx Unicorn Reopen"
    task :reopen, :roles => :app do
      sudo "/usr/sbin/nginx -s reopen;true"
    end

    task :ensure_system_log_location, :roles => :app do
      sudo "mkdir -p #{shared_path}/log" #make sure the log location exists or nginx barfs.
      sudo "mkdir -p /var/log/nginx"
      sudo "chown -R nobody:adm /var/log/nginx"
    end

    task :remove_default, :roles => :app do
      sudo "rm -f #{nginx_unicorn_root}/sites-enabled/default"
    end

    desc "Watch Nginx and Unicorn Workers with GOD"
    task :setup_god, :roles => :app do
      god.upload nginx_unicorn_god_path, "nginx_unicorn.god"
    end
    
    desc "Setup sd-agent to collect metrics for nginx"
    task :setup_sdagent, :roles => :app do
      # block executing this task if :sdagent isn't present on any :app servers.
      if (find_servers(:roles => :app).map{|d| d.host} && find_servers(:roles => :sdagent).map{|d| d.host}).any?
        sudo "sed -i 's/^.*nginx_status_url.*$/nginx_status_url: http:\\/\\/127.0.0.1\\/nginx_status/g' #{sdagent_root}/config.cfg"
      end
    end

    desc "Write the application conf"
    task :configure, :roles => :app do
      utilities.sudo_upload_template nginx_unicorn_app_conf_path, "#{nginx_unicorn_root}/sites-available/#{application}.conf"
      enable
    end

    desc "Enable the application conf"
    task :enable, :roles => :app do
      sudo "ln -sf #{nginx_unicorn_root}/sites-available/#{application}.conf #{nginx_unicorn_root}/sites-enabled/#{application}.conf"
    end

    desc "Disable the application conf"
    task :disable, :roles => :app do
      sudo "rm #{nginx_unicorn_root}/sites-enabled/#{application}.conf"
    end

  end
end
