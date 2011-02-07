# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :nginx do

    desc 'Installs nginx'
    task :install, :roles => :web do
      puts 'Installing Nginx'
      utilities.apt_install %w[nginx]
    end

  end
end
