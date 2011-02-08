# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :cassandra do
    desc "install cassandra"
    task :install, :roles => :db do
      #http://wiki.apache.org/cassandra/DebianPackaging
      put %Q{
        deb http://www.apache.org/dist/cassandra/debian unstable main
        deb-src http://www.apache.org/dist/cassandra/debian unstable main
      },'/tmp/cassandra.list'
      sudo "mv /tmp/cassandra.list /etc/apt/sources.list.d/cassandra.list"
      sudo "apt-key adv --keyserver keys.gnupg.net --recv-keys F758CE318D77295D"
      utilities.apt_upgrade
      utilities.apt_install "cassandra"
    end

  end
end
