Capistrano::Configuration.instance(true).load do

  namespace :rsyslog_server do
    set :rsyslog_server, 'logs.offerify.net'
    set :rsyslog_server_conf, File.join(File.dirname(__FILE__),'rsyslog-server.conf')
    set :rsyslog_demandchain_conf, File.join(File.dirname(__FILE__),'demandchain-rlog.conf')
    set :rsyslog_cron, File.join(File.dirname(__FILE__),'rsyslog-compress.cron')

    on :start, :only => "deploy:provision" do
      rsyslog_server.install
    end

    desc "Install All" # Seperate out Conf file setup/copy as seperate task in the future
    task :install, :roles => :rsyslog_server do
      rsyslog_server.install_apt
      rsyslog_server.setup_rsyslog_server_conf
      rsyslog_server.restart
    end
    
    desc "Install what we can from apt"
    task :install_apt, :roles => :rsyslog_server do
      utilities.apt_update
      utilities.apt_install %w[build-essential wget apache2 libapache2-mod-php5 pkg-config]
    end

    desc "Install rsyslogd server configuration file"
    task :setup_rsyslog_server_conf, :roles => :rsyslog_server do
      utilities.upload_template rsyslog_server_conf, "/tmp/rsyslog-server.conf"
      utilities.upload_template rsyslog_demandchain_conf, "/tmp/demandchain-rlog.conf"
      utilities.upload_template rsyslog_cron, "/tmp/rsyslog-compress.cron"
      sudo "mv /tmp/rsyslog-server.conf /etc/rsyslog.conf"
      sudo "mv /tmp/demandchain-rlog.conf /etc/rsyslog.d/demandchain.conf"
      sudo "mv /tmp/rsyslog-compress.cron /etc/cron.hourly/rsyslog-bz2"
    end

    desc "Restart rsyslog server"
    task :restart, :roles => :rsyslog_server do
      sudo "service rsyslog restart"
    end

  end

    namespace :rsyslog_client do
    set :rsyslog_client_conf, File.join(File.dirname(__FILE__),'rsyslog-client.conf')

    on :start, :only => "deploy:provision" do
      rsyslog_client.install
      rsyslog_client.setup_rsyslog_client_conf
      rsyslog_client.restart
    end

    desc "Install All" # Seperate out Conf file setup/copy as seperate task in the future
    task :install, :roles => :rsyslog_client do
      rsyslog_client.setup_rsyslog_client_conf
    end
    
    desc "Install rsyslogd server configuration file"
    task :setup_rsyslog_client_conf, :roles => :rsyslog_client do
      sudo "rm -rf /tmp/rsyslog-client.conf"
      utilities.upload_template rsyslog_client_conf, "/tmp/rsyslog-client.conf"
      sudo "mv /tmp/rsyslog-client.conf /etc/rsyslog.conf"
    end

    desc "Restart rsyslog server"
    task :restart, :roles => :rsyslog_client do
      sudo "service rsyslog restart"
    end
  end
 
end