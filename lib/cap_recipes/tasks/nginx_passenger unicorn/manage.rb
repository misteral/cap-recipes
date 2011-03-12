# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/install')


Capistrano::Configuration.instance(true).load do

  namespace :nginx_unicorn do

    set :nginx_unicorn_port, '80'
    set :nginx_unicorn_server_name, 'localhost'
    set :nginx_unicorn_app_conf_path, File.join(File.dirname(__FILE__),'app.conf')

    %w(start stop restart).each do |t|
      desc "#{t} nginx_unicorn"
      task t.to_sym, :roles => :db do
        sudo "/etc/init.d/#{nginx_unicorn_init_d} #{t}"
      end
    end
    
    desc "Write the application conf"
    task :configure, :roles => :app do
      utilities.sudo_upload_template nginx_unicorn_app_conf_path, "#{nginx_unicorn_path}/conf/sites-available/#{application}.conf"
      enable
    end

    desc "Enable the application conf"
    task :enable, :roles => :app do
      sudo "ln -sf #{nginx_unicorn_path}/conf/sites-available/#{application}.conf #{nginx_unicorn_path}/conf/sites-enabled/#{application}.conf"
    end

    desc "Disable the application conf"
    task :disable, :roles => :app do
      sudo "rm #{nginx_unicorn_path}/conf/sites-enabled/#{application}.conf"
    end

  end

end