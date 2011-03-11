# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

# This Nginx is targeted for the :web role meant to be acting as a load balancer

# TODO change app.conf to point to upstream something

Capistrano::Configuration.instance(true).load do
  set :nginx_root, "/etc/nginx"
  set :nginx_conf_path, File.join(File.dirname(__FILE__),'nginx.conf')
  set :nginx_init_d_path, File.join(File.dirname(__FILE__),'nginx.init')
  set :nginx_init_d, "nginx"

  namespace :nginx do

    desc 'Installs nginx'
    task :install, :roles => :web do
      puts 'Installing Nginx'
      utilities.apt_install %w[nginx]
    end

    task :setup, :roles => :web do
      sudo "mkdir -p #{nginx_root}/conf/sites-available #{nginx_root}/conf/sites-enabled"
      utilities.sudo_upload_template(nginx_conf_path,"#{nginx_root}/conf/nginx.conf")
    end

  end
end
