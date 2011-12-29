# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :mysql do
    roles[:mysqld]
    roles[:mysqld_backup]
    set(:mysql_admin_password) { utilities.ask "mysql_admin_password:"}
    set :mysql_restore_table_priorities, nil
    set :mysql_restore_source_name, nil
    set :mysql_client_user, nil
    set :mysql_client_pass, nil
    set :mysql_client_executable, "mysql"
    set :mysql_client_use_sudo, true
    set :mysql_restore_script, File.join(File.dirname(__FILE__),'mysql_restore.sh')
    set :mysql_restore_script_path, "/root/script/mysql_restore.sh"
    set :mysql_backup_archive_watermark, "0m"
    set :mysql_backup_s3_bucket, "mysql-backups"
    set :mysql_backup_log_path, "/tmp/mysql_backup.log"
    set(:mysql_backup_log_dest) {File.join(utilities.caproot,'log','backups')}
    set :mysql_backup_stop_sql_thread, false
    set :mysql_backup_script, File.join(File.dirname(__FILE__),'mysql_backup_s3.sh')
    set :mysql_backup_script_path, "/root/script/mysql_backup_s3.sh"
    set :mysql_backup_chunk_size, "250M"

    def mysql_client_cmd(cmd)
      command = []
      command << "#{sudo}" if mysql_client_use_sudo
      command << mysql_client_executable
      command << "-u#{mysql_client_user}" if mysql_client_user
      command << "-p#{mysql_client_pass}" if mysql_client_pass
      command << "-e \"#{cmd}\""
      command.join(" ")
    end

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

    desc "Install Mysql Developement Libraries"
    task :install_client_libs, :except => {:no_release => true} do
      utilities.apt_install "libmysqlclient-dev"
    end

    namespace :backup do

      desc "Transfer backup script to host"
      task :upload_backup_script, :roles => :mysqld_backup do
        run "#{sudo} mkdir -p /root/script"
        run "#{sudo} mkdir -p /mnt/mysql_backups"
        utilities.apt_install "at"
        utilities.sudo_upload_template mysql_backup_script, mysql_backup_script_path, :mode => "654", :owner => 'root:root'
        utilities.sudo_upload_template mysql_restore_script, mysql_restore_script_path, :mode => "654", :owner => 'root:root'
      end

      desc "Trigger Backup"
      task :trigger, :roles => :mysqld_backup do
        upload_backup_script
        remove_backup_log
        sudo %Q{sh -c "echo '/root/script/mysql_backup_s3.sh > #{mysql_backup_log_path} 2>&1' | at now + 2 minutes"}
      end

      desc "validate backup"
      task :verify, :roles => :mysqld_backup do
        begin
          ensure_slave_running
          retrieve_backup_log
          check_backup_finished
        ensure
          remove_backup_log
        end
      end

      desc "checks that the backup appears to have finished"
      task :check_backup_finished, :roles => :mysqld_backup do
        run "grep 'MYSQL BACKUP FINISHED' #{mysql_backup_log_path}"
      end

      desc "retreive the backup log"
      task :retrieve_backup_log, :roles => :mysqld_backup do
        run_locally "mkdir -p #{mysql_backup_log_dest}"
        top.download mysql_backup_log_path, "#{mysql_backup_log_dest}/backup-$CAPISTRANO:HOST$.log", :via => :scp
      end

      desc "remove the backup log"
      task :remove_backup_log, :roles => :mysqld_backup do
        sudo "rm -f #{mysql_backup_log_path}"
      end

      desc "ensure slave is running"
      task :ensure_slave_running, :roles => :mysqld_backup do
        if mysql_backup_stop_sql_thread
          # It should be started, intervene if it's not.
          begin
            run %Q{test `#{mysql_client_cmd("SHOW SLAVE STATUS\G")} | grep Running | grep -c Yes` = '2'}
          rescue => e
            raise Capistrano::Error, "Mysql threads are not running #{e.message}"
          ensure
            run mysql_client_cmd("START SLAVE")
          end
        end
      end



    end


  end

end