# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

# This Nginx is targeted for the :app role meant to be acting as a front end
# to phusion passenger based application

#TODO nginx.init needs to be customized

Capistrano::Configuration.instance(true).load do

  namespace :nginx_passenger do

    set :nginx_passenger_root, '/opt/nginx'
    set :nginx_passenger_conf_path, File.join(File.dirname(__FILE__),'nginx.conf')
    set :nginx_passenger_init_d_path, File.join(File.dirname(__FILE__),'nginx.init')
    set :nginx_passenger_init_d, "nginx"

    desc 'Installs nginx_passenger'
    task :install, :roles => :app do
      puts 'Installing Nginx_Passenger'
      utilities.apt_install "libssl-dev zlib1g-dev libcurl4-openssl-dev"
      utilities.gem_install "passenger"
      sudo "passenger-install-nginx-module --auto --auto-download --prefix=#{nginx_passenger_root}"
      setup
    end

    task :setup, :roles => :app do
      sudo "mkdir -p #{nginx_passenger_root}/sites-available #{nginx_passenger_root}/sites-enabled"
      utilities.sudo_upload_template nginx_passenger_conf_path, "#{nginx_passenger_root}/conf/nginx.conf"
      utilities.sudo_upload_template nginx_passenger_init_d_path,"/etc/init.d/#{nginx_passenger_init_d}", :mode => "u+x"
    end

  end
end
