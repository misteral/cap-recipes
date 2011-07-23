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
    set(:riak_pkg_name) { riak_pkg.match(/\/([^\/]*)$/)[1] }
    set :riak_from_source, false
    set :riak_erlang_ver, "otp_src_R13B04"
    set :target_os, :ubuntu64
    set :riak_app_config_path, File.join(File.dirname(__FILE__),'app.config')
    set :riak_vm_args_path, File.join(File.dirname(__FILE__),'vm.args')

    desc "install riak"
    task :install, :roles => :riak do
      utilities.apt_install %w[build-essential libc6-dev wget]
      set :erlang_ver, riak_erlang_ver
      #Erlang is a dependency for anything running riak need to add them to the erlang role.
      roles[:erlang].push(*roles[:riak].to_ary)
      erlang.install
      if riak_from_source
        install_from_source
      else
        install_from_package
      end
      riak.setup
    end

    task :install_from_source,  :roles => :riak  do
      #TODO: move binaries into place
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{riak_src} && #{sudo} tar xzf #{riak_ver}.tar.gz"
      run "cd /usr/local/src/#{riak_ver} && #{sudo} make rel"
    end

    task :install_from_package,  :roles => :riak do
      sudo "wget --tries=2 -c --directory-prefix=/usr/local/src --progress=bar:force #{riak_pkg}"
      sudo "dpkg -i /usr/local/src/#{riak_pkg_name}"
    end
    
    desc "Setup riak"
    task :setup, :roles => :riak do
      utilities.sudo_upload_template riak_app_config_path, "/etc/riak/app.config", :mode => "640", :owner => 'root:riak'
      utilities.sudo_upload_template riak_vm_args_path, "/etc/riak/vm.args", :mode => "640", :owner => 'root:riak'
    end

  end
end