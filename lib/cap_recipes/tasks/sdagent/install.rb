# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')


Capistrano::Configuration.instance(true).load do

  namespace :sdagent do

    set :sdagent_root, "/etc/sd-agent"
    set :sdagent_bin, "/usr/bin/sd-agent"
    set(:sdagent_plugins_dir) { File.join(sdagent_root,"plugins")}

    #todo: deal with adding the unique key for the configuration
    task :install do
      sudo "wget http://www.serverdensity.com/downloads/boxedice-public.key"
      sudo "apt-key add boxedice-public.key; rm -f boxedice-public.key"
      put %Q{
        deb http://www.serverdensity.com/downloads/linux/debian lenny main
      },'/tmp/serverdensity.list'
      sudo "mv /tmp/serverdensity.list /etc/apt/sources.list.d/serverdensity.list"
      utilities.apt_update
      utilities.apt_install "sd-agent python-mysqldb python-dev"
      sdagent.setup
      sdagent.restart
    end

    task :update do
      utilities.apt_update
      utilities.apt_install "sd-agent"
    end
    
    task :setup do
      sudo "mkdir -p #{sdagent_plugins_dir}"
    end

  end
end
