# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/install')

Capistrano::Configuration.instance(true).load do

  namespace :nginx do

    set :nginx_port, '80'
    set :nginx_server_name, 'localhost'
    set :nginx_app_conf_path, File.join(File.dirname(__FILE__),'app.conf')

    %w(start stop restart).each do |t|
      desc "#{t} nginx"
      task t.to_sym, :roles => :db do
        sudo "/etc/init.d/#{nginx_init_d} #{t}"
      end
    end

    desc "Write the application conf"
    task :configure, :roles => :app do
      utilities.sudo_upload_template nginx_app_conf_path, "#{nginx_path}/sites-available/#{application}.conf"
      enable
    end

    desc "Enable the application conf"
    task :enable, :roles => :app do
      sudo "ln -sf #{nginx_path}/sites-available/#{application}.conf #{nginx_path}/sites-enabled/#{application}.conf"
    end

    desc "Disable the application conf"
    task :disable, :roles => :app do
      sudo "rm #{nginx_path}/sites-enabled/#{application}.conf"
    end

  end

end