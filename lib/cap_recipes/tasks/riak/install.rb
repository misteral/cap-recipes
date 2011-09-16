# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/../aptitude/manage')
require File.expand_path(File.dirname(__FILE__) + '/../erlang/install')

Capistrano::Configuration.instance(true).load do

  namespace :riak do
    roles[:riak]
    set :riak_src, "http://downloads.basho.com/riak/riak-0.14/riak-0.14.2.tar.gz"
    set(:riak_ver) { riak_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }
    set(:riak_pkg) {
      case target_os
      when :debian64, :ubuntu64
        "http://downloads.basho.com/riak/riak-0.14/riak_0.14.2-1_amd64.deb"
      when :debian32, :ubuntu32
        "http://downloads.basho.com/riak/riak-0.14/riak_0.14.2-1_i386.deb"
      else
        raise Capistrano::Error "Unhandled target_os in :riak"
      end
    }
    # this recipe temporarily only works for git installed riak 1.0 because of incompatable dependencies of erlang.
    # will standardize the other methods when 1.0 is released.
    set :riak_git_ref, "riak-1.0.0pre3"
    set :riak_git_repo, "https://github.com/basho/riak.git"
    set(:riak_pkg_name) { riak_pkg.match(/\/([^\/]*)$/)[1] }
    set :riak_erlang_ver, "otp_src_R14B03"
    set :target_os, :ubuntu64
    set :riak_app_config_path, File.join(File.dirname(__FILE__),'app.config')
    set :riak_vm_args_path, File.join(File.dirname(__FILE__),'vm.args')
    set :riak_monit_path, File.join(File.dirname(__FILE__),'riak.monit')
    set :riak_god_path, File.join(File.dirname(__FILE__),'riak.god')
    set :riak_listen, 'localhost'
    set :riak_handoff_port, "8099"
    set :riak_http_port, "8098"
    set :riak_https_port, "8100"
    set :riak_pb_port, "8087"
    set :riak_name, 'riak'
    set :riak_install_from, :git
    set :riak_search, true
    set :riak_ring_creation_size, '512'
    set :riak_backend, "riak_kv_eleveldb_backend" # riak_kv_eleveldb_backend | riak_kv_bitcask_backend
    set(:riak_root) {
      #TODO: not fully plumbed, :package does it's own thing and ignores this, :source SHOULD use it but doesn't yet.
      case riak_install_from
      when :source, :git
        "/opt/riak"
      when :package
        "/usr/local"
      end
    }
    set(:riak_etc) {
      case riak_install_from
      when :source, :package
        "/etc/riak"
      when :git
        "#{riak_root}/etc"
      end
    }

    desc "install riak"
    task :install, :roles => :riak do
      utilities.apt_install %w[build-essential libc6-dev wget]
      set :erlang_ver, riak_erlang_ver
      #Erlang is a dependency for anything running riak need to add them to the erlang role.
      roles[:erlang].push(*roles[:riak].to_ary)
      erlang.install
      riak.send("install_from_#{riak_install_from}".to_sym)
      riak.setup
    end

    task :install_from_source,  :roles => :riak  do
      #TODO: move binaries into place
      utilities.addgroup "riak", :system => true
      utilities.adduser "riak" , :nohome => true, :group => "riak", :system => true, :disabled_login => true
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{riak_src} && #{sudo} tar xzf #{riak_ver}.tar.gz"
      run "cd /usr/local/src/#{riak_ver} && #{sudo} make clean rel"
    end

    task :install_from_package,  :roles => :riak do
      sudo "wget --tries=2 -c --directory-prefix=/usr/local/src --progress=bar:force #{riak_pkg}"
      sudo "dpkg -i /usr/local/src/#{riak_pkg_name}"
    end

    task :install_from_git, :roles => :riak do
      utilities.addgroup "riak", :system => true
      utilities.adduser "riak" , :nohome => true, :group => "riak", :system => true, :disabled_login => true
      #TODO: beginning new pattern of installing things that are compiled to /opt/<package>/[src|etc|bin|var]
      #This dovetails with mounting ebs volumes to /opt and putting your most important apps there including their data.
      utilities.git_clone_or_pull riak_git_repo, "#{riak_root}/src", riak_git_ref
      run "cd #{riak_root}/src && #{sudo} rm -rf #{riak_root}/src/rel/riak && #{sudo} make rel"
    end

    desc "Setup riak"
    task :setup, :roles => :riak do
      utilities.sudo_upload_template riak_app_config_path, "#{riak_etc}/app.config", :mode => "640", :owner => 'root:riak'
      utilities.sudo_upload_template riak_vm_args_path, "#{riak_etc}/vm.args", :mode => "640", :owner => 'root:riak'
    end

    desc "setup monit to watch riak"
    task :setup_monit, :roles => :riak do
      monit.upload(riak_monit_path,"riak.monit")
    end

    desc "setup god to watch riak"
    task :setup_god, :roles => :riak do
      god.upload(riak_god_path,"riak.god")
    end

    %w(start stop restart ping force-reload).each do |t|
      desc "#{t} riak"
      task t.to_sym, :roles => :riak do
        sudo "/etc/init.d/riak #{t}"
      end
    end
  end
end