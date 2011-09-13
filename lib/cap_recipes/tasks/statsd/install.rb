Capistrano::Configuration.instance(true).load do

  namespace :statsd do
    
    set :statsd_conf, File.join(File.dirname(__FILE__),'statsd.js')
    set :statsd_init, File.join(File.dirname(__FILE__),'statsd.conf')
    set :statsd_god_path, File.join(File.dirname(__FILE__),'statsd.god')
    
    desc "install Node.js and StatsD and start/restart daemons"
    task :install do
      statsd.install_packages
      statsd.install_node
      statsd.install_statsd
      statsd.setup
      statsd.restart
    end

    desc "install all necessary apt packages"
    task :install_packages, :roles => :app do
      utilities.apt_install %[git-core python-setuptools]
    end
    
    before "statsd:install_packages", "aptitude:updates"

    desc "Install Node.js"
    task :install_node, :roles => :app do
      sudo "git clone https://github.com/joyent/node /opt/node"
      run "cd /opt/node/ && #{sudo} ./configure && #{sudo} make && #{sudo} make install"
    end

    desc "Install Etsy Statsd"
    task :install_statsd, :roles => :app do
      sudo " git clone https://github.com/etsy/statsd.git /opt/statsd"
    end

    task :setup, :roles => :app do
      statsd.setup_statsd_conf
      statsd.setup_statsd_init
      statsd.setup_statsd_start
      statsd.setup_god
    end
    
    desc "Setup Statsd Server config"
    task :setup_statsd_conf, :roles => :app do
      sudo "mkdir -p /etc/statsd"
      utilities.sudo_upload_template statsd_conf, "/etc/statsd/statsd.js", :mode => "644", :owner => 'nobody:nogroup'
    end
    
    desc "Setup Statsd Server Start Script"
    task :setup_statsd_start, :roles => :app do
      sudo "mkdir -p /usr/share/statsd/scripts"
      utilities.sudo_upload_template statsd_conf, "/usr/share/statsd/scripts/start", :mode => "644", :owner => 'nobody:nogroup'
    end
    
    desc "Setup Statsd Init"
    task :setup_statsd_init, :roles => :app do
      utilities.sudo_upload_template statsd_init, "/etc/init/statsd.conf", :mode => "644", :owner => 'root:root'
    end
    
    desc "Start/Restart Services"
    task :setup_statsd_start, :roles => :app do
      sudo "service statsd stop;true"
      sudo "service statsd start"
    end
    
    desc "setup god to watch statsd"
    task :setup_god, :roles => :app do
      god.upload(statsd_god_path,"statsd.god")
    end
          
  end 
   
end