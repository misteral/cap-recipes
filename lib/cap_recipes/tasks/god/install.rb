Capistrano::Configuration.instance(true).load do

  namespace :god do

    set(:god_daemon) {"#{base_ruby_path}/bin/god"}
    set(:god_config) {"/etc/god/config.god"}
    set(:god_confd) {"/etc/god/conf.d"}
    set :god_config_path, File.join(File.dirname(__FILE__),'config.god')
    set(:god_init) {"/etc/init.d/god"}
    set :god_init_path, File.join(File.dirname(__FILE__),'god.init')
    set :god_contacts_path, File.join(File.dirname(__FILE__),'contacts.god')
    set(:god_log_path) {"/var/log/god.log"}
    set(:god_pid_path) {"/var/run/god.pid"}
    set :god_notify_list, "localhost"

    def cmd(cmd,options={})
      r_env = options[:rails_env] || rails_env
      sudo "PATH=#{base_ruby_path}/bin:$PATH #{god_daemon} #{cmd}"
    end

    # Use this helper to upload god conf.d files and reload god
    # god.upload god_contacts_path, "contacts.god"
    def upload(src,name)
      utilities.sudo_upload_template src, "#{god_confd}/#{name}"
      god.reload
    end
    
    # TODO: update rubies other than ruby19 to conform
    # New Concept ':except => {:no_ruby => true}' to allow all systems by default 
    # to have ruby installed to allow use of ruby gems like god on all systems
    # regardless of whether they have releases deployed to them, they may have other things
    # that we want god to watch on them.

    desc "install god init"
    task :install, :except => {:no_ruby => true} do
      utilities.gem_install "god"
      utilities.sudo_upload_template god_init_path, god_init, :mode => "+x"
      sudo "update-rc.d -f god defaults"
    end
    
    desc "setup god"
    task :setup, :except => {:no_ruby => true} do
      sudo "mkdir -p #{god_confd}"
      utilities.sudo_upload_template god_config_path, god_config
    end

    desc "upload god contacts"
    task :contacts do
      god.upload god_contacts_path, 'contacts.god'
    end

    %w(start stop restart status).each do |t|
      desc "#{t} God"
      task t.to_sym, :except => {:no_ruby => true} do
        sudo "/etc/init.d/god #{t}"
      end
    end

    desc "reload the god config"
    task :reload, :except => {:no_ruby => true} do
      god.cmd "load #{god_config};true"
    end
    
    desc "terminate god and everything it's watching"
    task :terminate, :except => {:no_ruby => true } do
      god.cmd "terminate"
    end

  end
end
