# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :nginx_passenger do

    set :nginx_passenger_path, '/opt/nginx'

    #TODO: init scripts

    desc 'Installs nginx_passenger'
    task :install, :roles => :app do
      puts 'Installing Nginx_Passenger'
      utilities.apt_install "libssl-dev zlib1g-dev libcurl4-openssl-dev"
      utilities.gem_install "passenger"
      sudo "passenger-install-nginx-module --auto --auto-download --prefix=#{nginx_passenger_path}"
      setup
    end

    task :setup, :roles => :app do
      sudo "mkdir -p #{nginx_passenger_path}/conf/sites-available #{nginx_passenger_path}/conf/sites-enabled"
      utilities.sudo_upload_template('nginx_passenger/nginx.conf',"#{nginx_passenger_path}/conf/nginx.conf")
    end

  end
end
