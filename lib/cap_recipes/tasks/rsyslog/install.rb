# @author Rick Russell sysadmin.rick@gmail.com
# Make sure all TODO items in rsyslog-apache.conf(4,17), rsyslog-client.conf(79) and this install.rb(65) are set
Capistrano::Configuration.instance(true).load do

  namespace :rsyslog_server do
    roles[:rsyslog_server]
    set :rsyslog_server_conf, File.join(File.dirname(__FILE__),'rsyslog-server.conf')
    set :rsyslog_default_conf, File.join(File.dirname(__FILE__),'default-rsyslog.conf')
    set :rsyslog_cron, File.join(File.dirname(__FILE__),'rsyslog-compress.cron')
    set :rsyslog_apache_conf, File.join(File.dirname(__FILE__),'rsyslog_apache.conf')
    set :log_ananalyzer_src, "http://download.adiscon.com/loganalyzer/loganalyzer-3.2.2.tar.gz"
    set(:log_ananalyzer_ver) { log_ananalyzer_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }

    desc "Install All"
    task :install, :roles => :rsyslog_server do
      rsyslog_server.install_apt
      rsyslog_server.setup_rsyslog_server_conf
      rsyslog_server.restart_apache
      rsyslog_server.restart
    end

    desc "Install what we can from apt"
    task :install_apt, :roles => :rsyslog_server do
      utilities.apt_update
      utilities.apt_install %w[build-essential wget rsyslog rsyslog-relp apache2 libapache2-mod-php5 php5-mysql php5-gd pkg-config]
    end

    desc "Install Log Analyzer Web Interface"
    task :install_log_analyzer, :roles => :rsyslog_server do
      sudo "mkdir -p /var/www/rsyslog"
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{log_ananalyzer_src} && #{sudo} tar --no-same-owner -xzf #{log_ananalyzer_ver}.tar.gz"
      run "cd /usr/local/src/#{log_ananalyzer_ver} && #{sudo} ./configure && #{sudo} make && #{sudo} make install"
    end

    desc "Setup rsyslogd server configuration file"
    task :setup_rsyslog_server_conf, :roles => :rsyslog_server do
      utilities.upload_template rsyslog_server_conf, "/tmp/rsyslog-server.conf"
      utilities.upload_template rsyslog_default_conf, "/tmp/default-rsyslog.conf"
      utilities.upload_template rsyslog_apache_conf, "/tmp/rsyslog-apache.conf"
      utilities.upload_template rsyslog_cron, "/tmp/rsyslog-compress.cron"
      sudo "mv /tmp/rsyslog-server.conf /etc/rsyslog.conf"
      sudo "mv /tmp/default-rsyslog.conf /etc/rsyslog.d/default-rsyslog.conf"
      sudo "mv /tmp/rsyslog-apache.conf /etc/apache2/sites-available/rsyslog-apache.conf"
      sudo "mv /tmp/rsyslog-compress.cron /etc/cron.hourly/rsyslog-bz2"
    end

    desc "Restart Apache"
      task :restart_apache, :roles => :rsyslog_server do
      sudo "a2ensite observer"
      sudo "apache2ctl restart"
    end

    desc "Restart rsyslog daemon"
    task :restart, :roles => :rsyslog_server do
      sudo "service rsyslog restart"
    end

  end

  namespace :rsyslog_client do
    roles[:rsyslog_client]
    set :rsyslog_client_conf, File.join(File.dirname(__FILE__),'rsyslog-client.conf')
    set :rsyslog_client_regexed_programs_logrotate_conf, File.join(File.dirname(__FILE__),'regexed_programs.logrotate')
    #TODO Edit the following regexed items to match your environment.  I have more than you may need.
    set :rsyslog_client_regexed_programs, %w(named dhcpd hddtemp collectd slapd imapd unicorn riak redis apache god haproxy)

    on :start, :only => "deploy:provision" do
      rsyslog_client.install
    end

    desc "Install All" # Seperate out Conf file setup/copy as seperate task in the future
    task :install, :roles => :rsyslog_client do
      rsyslog_client.install_apt
      rsyslog_client.setup_rsyslog_client_conf
      rsyslog_client.setup_regexed_programs_logrotate
      rsyslog_client.restart
    end

        desc "Install what we can from apt"
    task :install_apt, :roles => :rsyslog_client do
      utilities.apt_update
      utilities.apt_install %w[build-essential wget rsyslog rsyslog-relp]
    end

    desc "Install rsyslogd server configuration file"
    task :setup_rsyslog_client_conf, :roles => :rsyslog_client do
      utilities.sudo_upload_template rsyslog_client_conf, "/etc/rsyslog.conf"
    end

    desc "Install logrotate configuration file for regexed programs"
    task :setup_regexed_programs_logrotate, :roles => :rsyslog_client do
      utilities.sudo_upload_template rsyslog_client_regexed_programs_logrotate_conf, "/etc/logrotate.d/regexed_programs"
      run "cd /var/log && #{sudo} touch #{rsyslog_client_regexed_programs.map{|p| "#{p}.log"}.join(' ')} && #{sudo} chown syslog:adm #{rsyslog_client_regexed_programs.map{|p| "#{p}.log"}.join(' ')}"
    end

    desc "Restart rsyslog daemon"
    task :restart, :roles => :rsyslog_client do
      sudo "service rsyslog stop;true"
      sudo "service rsyslog start"
    end

  end

end
