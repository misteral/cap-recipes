# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :newrelic_rpm do
    roles[:newrelic_rpm]
    set(:newrelic_rpm_license_key) {utilities.ask("newrelic_rpm_license_key:")}
    set :newrelic_rpm_watcher, nil
    set :newrelic_rpm_suppress_runner, false
    set :newrelic_rpm_god_path, File.join(File.dirname(__FILE__),'newrelic_rpm.god')
    set :newrelic_rpm_gem_ver, "3.3.0"
    set :newrelic_rpm_contrib_gem_ver, "2.1.6"

    desc 'Installs newrelic_rpm'
    task :install, :roles => :newrelic_rpm do
      utilities.gem_install "newrelic_rpm", newrelic_rpm_gem_ver
      utilities.gem_install "rpm_contrib", newrelic_rpm_contrib_gem_ver
      sudo "curl -L http://download.newrelic.com/debian/newrelic.list -o /etc/apt/sources.list.d/newrelic.list"
      utilities.apt_update
      utilities.apt_install 'newrelic-sysmond'
    end

    desc "Setup newrelic_rpm"
    task :setup, :roles => :newrelic_rpm do
      sudo "nrsysmond-config --set license_key=#{newrelic_rpm_license_key}"
    end

    desc "select watcher"
    task :watcher do 
      newrelic_rpm.send("watch_with_#{newrelic_rpm_watcher}".to_sym) unless newrelic_rpm_watcher.nil?
    end

    desc "Use GOD as newrelic_rpm's runner"
    task :watch_with_god do
      #rejigger the maintenance tasks to use god when god is in play
      %w(start stop restart).each do |t|
        task t.to_sym, :roles => :newrelic_rpm do
          god.cmd "#{t} newrelic-sysmond" unless newrelic_rpm_suppress_runner
        end
      end
      after "god:setup", "newrelic_rpm:setup_god"
    end

    desc "setup god to watch newrelic_rpm"
    task :setup_god, :roles => :newrelic_rpm do
      god.upload newrelic_rpm_god_path, 'newrelic_rpm.god'
    end

    %w(start stop restart).each do |t|
      desc "#{t} newrelic-sysmond"
      task t.to_sym, :roles => :newrelic_rpm do
        sudo "/etc/init.d/newrelic-sysmond #{t}"
      end
    end

  end
end
