# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :postfix do

    desc 'Installs postfix'
    task :install, :roles => :web do
      puts 'Installing Postfix'
      utilities.apt_install "postfix"
    end

    #TODO: setup tasks create a basic forwarder from a template

  end
end
