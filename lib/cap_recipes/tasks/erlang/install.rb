# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :erlang do
    set :erlang_ver, "otp_src_R13B04"
    set(:erlang_src) {"http://erlang.org/download/#{erlang_ver}.tar.gz"}
    set :erlang_prefix, '/usr'

    desc 'Installs erlang'
    task :install, :roles => :erlang do
      utilities.apt_install "build-essential libncurses5-dev openssl libssl-dev"
      #TODO: things that use a prefix should probably be built in that prefix's source dir
      # ie: /usr/src or /usr/local/src etc.  /opt/package/src or /opt/src would probably be appropriate too
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{erlang_src} && #{sudo} tar xzf #{erlang_ver}.tar.gz"
      run "cd /usr/local/src/#{erlang_ver} && #{sudo} ./configure --prefix=#{erlang_prefix} && #{sudo} make install"
    end

    desc "Return the installed erlang version"
    task :version, :roles => :erlang do
      run %Q{erl -noshell -eval 'io:fwrite(erlang:system_info(otp_release)), io:fwrite("\n"), init:stop().'}
    end

  end
end
