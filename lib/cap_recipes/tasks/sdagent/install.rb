# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')


Capistrano::Configuration.instance(true).load do

  namespace :sdagent do
    #todo: deal with adding the unique key for the configuration
    task :install do
      utilities.apt_install "sd-agent python-mysqldb python-dev"
    end
    
    task :update do 
      utilities.apt_update
      install
    end
    
  end
end
