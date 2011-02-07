# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')


Capistrano::Configuration.instance(true).load do

  namespace :nginx_passenger do

    set :nginx_passenger_port, '80'
    set :nginx_passenger_server_name, ''

    #TODO: start stop restart

    desc "Write the application conf"
    task :configure, :roles => :app do
      utilities.sudo_put_template "nginx_passenger/app.conf", "#{nginx_passenger_path}/conf/sites-available/#{application}.conf"
      enable
    end

    desc "Enable the application conf"
    task :enable, :roles => :app do
      sudo "ln -sf #{nginx_passenger_path}/conf/sites-available/#{application}.conf #{nginx_passenger_path}/conf/sites-enabled/#{application}.conf"
    end

    desc "Disable the application conf"
    task :disable, :roles => :app do
      sudo "rm #{nginx_passenger_path}/conf/sites-enabled/#{application}.conf"
    end

  end

end