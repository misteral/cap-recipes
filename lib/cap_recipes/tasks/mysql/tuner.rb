# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :mysql_tuner do
    set :mysql_tuner_src, "mysqltuner.pl"
    set :mysql_tuner_src_url, "https://github.com/rackerhacker/MySQLTuner-perl.git"
    set :mysql_tuner_name, "MySQLTuner-perl"

    task :default do
      setup
      invoke
    end

    desc "install mysqltuner script"
    task :install, :roles => [:db] do
      utilities.run_compressed %Q{
        if [ -d /usr/local/src/#{mysql_tuner_name} ]; then
          cd /usr/local/src/#{mysql_tuner_name};
          #{sudo} git pull;
        else
          #{sudo} git clone #{mysql_tuner_src_url} /usr/local/src/#{mysql_tuner_name};
        fi
      }
      sudo "cp /usr/local/src/#{mysql_tuner_name}/mysqltuner.pl /usr/local/bin/mysqltuner.pl"
      sudo "chmod 0755 /usr/local/bin/mysqltuner.pl"
    end

    desc "execute mysqltuner script"
    task :invoke, :roles => [:db] do
      sudo "/usr/local/bin/mysqltuner.pl --user root --pass #{mysql_admin_password}"
    end
  end

end
