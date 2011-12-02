Capistrano::Configuration.instance(true).load do

  namespace :autossh do
  	roles[:autossh]
    set :autossh_init, File.join(File.dirname(__FILE__),'autossh.sh')

    on :start, :only => "deploy:provision" do
      autossh.install
    end

    desc "Grandfather install task"
    task :install, :roles => :autossh do
      autossh.install_autossh
      autossh.install_init
    end

    desc "Install autossh from apt"
    task :install, :roles => :autossh do
      utilities.apt_install "autossh"
    end

    desc "Upload autossh init"
    task :install_init, :roles => :autossh do
      utilities.upload_template autossh_init, "/etc/init.d/autossh"
      utilities.run_compressed %Q{
        #{sudo} chown root:root /etc/init.d/autossh;
        #{sudo} chmod 0644 /etc/init.d/autossh;
      }
    end

    desc "Install sudeoers file"
    task :start, :roles => :autossh do
      utilities.run_compressed %Q{
        #{sudo} /etc/init.d/autossh start
      }
    end

  end

end