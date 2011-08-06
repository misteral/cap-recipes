# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :erlang do
    set :erlang_ver, "otp_src_R13B04"
    set(:erlang_src) {"http://erlang.org/download/#{erlang_ver}.tar.gz"}

    desc 'Installs erlang'
    task :install, :roles => :erlang do
      utilities.apt_install "build-essential libncurses5-dev openssl libssl-dev"
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{erlang_src} && #{sudo} tar xzf #{erlang_ver}.tar.gz"
      run "cd /usr/local/src/#{erlang_ver} && #{sudo} ./configure && #{sudo} make install"
    end

  end
end
