# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

# This Nginx is targeted for the :app role meant to be acting as a front end 
# to a unicorn based application

#TODO the current configuration isn't enough to get unicorn working
#TODO more integration with the unicorn management tasks is required.
#TODO init.d needs to be customized
Capistrano::Configuration.instance(true).load do

  namespace :nginx_unicorn do

    set :nginx_unicorn_root, "/etc/nginx"
    set :nginx_unicorn_conf_path, File.join(File.dirname(__FILE__),'nginx.conf')
    set :nginx_unicorn_init_d_path, File.join(File.dirname(__FILE__),'nginx.init')
    set :nginx_unicorn_stub_conf_path, File.join(File.dirname(__FILE__),'stub_status.conf')
    set :nginx_unicorn_init_d, "nginx"
    
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

  end
end
