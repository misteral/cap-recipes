# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :sdagent do
    roles[:sdagent]
    set :sdagent_root, "/etc/sd-agent"
    set :sdagent_bin, "/usr/bin/sd-agent"
    set(:sdagent_plugins_dir) { File.join(sdagent_root,"plugins")}
    set :sdagent_suppress_runner, false
    set :sdagent_watcher, nil
    set :sdagent_god_path, File.join(File.dirname(__FILE__),'sdagent.god')

    #todo: deal with adding the unique key for the configuration
    task :install, :roles => :sdagent do
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

    desc "select watcher"
    task :watcher do
      sdagent.send("watch_with_#{sdagent_watcher}".to_sym) unless sdagent_watcher.nil?
    end

    desc "Use GOD as sdagents's runner"
    task :watch_with_god do
      #rejigger the maintenance tasks to use god when god is in play
      %w(start stop restart).each do |t|
        task t.to_sym, :roles => :app do
          god.cmd "#{t} sdagent" unless sdagent_suppress_runner
        end
      end
      before "god:restart", "sdagent:setup_god"
    end

    desc "setup god to watch sdagent"
    task :setup_god, :roles => :sdagent do
      god.upload sdagent_god_path, 'sdagent.god'
      #disable init from automatically starting and stopping sd-agent, giving ec2 instances a chance 
      #to change thier hostname before reporting in to serverdensity
      #but leave the init script in place to be called manally
      sudo "update-rc.d -f sd-agent remove"
      #if you simply remove lsb driven links an apt-get can later reinstall them
      #so we explicitly define the kill scripts.
      sudo "update-rc.d sd-agent stop 20 2 3 4 5 ."
    end
    
    task :update, :roles => :sdagent do
      utilities.apt_update
      utilities.apt_install "sd-agent"
    end
    
    task :setup, :roles => :sdagent do
      sudo "mkdir -p #{sdagent_plugins_dir}"
    end

  end
end
