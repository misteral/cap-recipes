# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :mysql do
    roles[:mysqld] #make an empty role
    set(:mysql_admin_password) { utilities.ask "mysql_admin_password:"}
    set :mysql_backup_script, File.join(File.dirname(__FILE__),'mysql_backup_s3.sh')
    set :mysql_backup_script_path, "/root/script/mysql_backup_s3.sh"
    set :mysql_restore_script, File.join(File.dirname(__FILE__),'mysql_restore.sh')
    set :mysql_restore_script_path, "/root/script/mysql_restore.sh"
    set :mysql_restore_table_priorities, nil
    set :mysql_restore_source_name, nil
    set :mysql_backup_stop_sql_thread, false

    desc "Install Mysql-server"
    task :install, :roles => :mysqld do
      #TODO: check password security, something seems off after install
      #http://serverfault.com/questions/19367/scripted-install-of-mysql-on-ubuntu
      begin
        put %Q{
          Name: mysql-server/root_password
          Template: mysql-server/root_password
          Value: #{mysql_admin_password}
          Owners: mysql-server-5.1
          Flags: seen

          Name: mysql-server/root_password_again
          Template: mysql-server/root_password_again
          Value: #{mysql_admin_password}
          Owners: mysql-server-5.1
          Flags: seen

          Name: mysql-server/root_password
          Template: mysql-server/root_password
          Value: #{mysql_admin_password}
          Owners: mysql-server-5.0
          Flags: seen

          Name: mysql-server/root_password_again
          Template: mysql-server/root_password_again
          Value: #{mysql_admin_password}
          Owners: mysql-server-5.0
          Flags: seen
        }, "non-interactive.txt"
        sudo "DEBIAN_FRONTEND=noninteractive DEBCONF_DB_FALLBACK=Pipe apt-get -qq -y install mysql-server < non-interactive.txt"
      rescue
        raise
      ensure
        sudo "rm non-interactive.txt"
      end

    end

    desc "Transfer backup script to host"
    task :upload_backup_script, :roles => :mysqld do
      run "#{sudo} mkdir -p /root/script"
      run "#{sudo} mkdir -p /mnt/mysql_backups"
      utilities.sudo_upload_template mysql_backup_script, mysql_backup_script_path, :mode => "654", :owner => 'root:root'
      utilities.sudo_upload_template mysql_restore_script, mysql_restore_script_path, :mode => "654", :owner => 'root:root'
    end

    desc "Run Backup"
    task :run_backup, :roles => :mysqld do
      upload_backup_script
      run "#{sudo} /root/script/mysql_backup_s3.sh"
    end

    desc "Install Mysql Developement Libraries"
    task :install_client_libs, :except => {:no_release => true} do
      utilities.apt_install "libmysqlclient-dev"
    end

  end

end