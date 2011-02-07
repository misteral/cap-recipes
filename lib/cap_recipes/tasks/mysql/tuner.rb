# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  #TODO refactor run's and cd's to proper sudos

  namespace :mysql_tuner do
    set :mysql_tuner_src, "mysqltuner.pl"
    set :mysql_tuner_src_url, "mysqltuner.pl/#{mysql_tuner_src}.gz"

    task :default do
      setup
      invoke
    end

    desc "install mysqltuner script"
    task :setup, :roles => [:db] do
      run "cd /usr/local/src && wget --tries=2 -c --progress=bar:force #{mysql_tuner_src_url} && gunzip --force #{mysql_tuner_src}.gz"
      run "cp /usr/local/src/mysqltuner.pl /usr/local/bin/mysqltuner.pl"
      run "chmod 0700 /usr/local/bin/mysqltuner.pl"
    end

    desc "execute mysqltuner script"
    task :invoke, :roles => [:db], :only => { :primary => true } do
      run "/usr/local/bin/mysqltuner.pl -user root -pass #{mysql_password_root}"
    end
  end

end
