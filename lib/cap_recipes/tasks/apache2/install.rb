require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :apache2 do
    roles[:apache2]
    set :apache2_with_php, true

    desc 'Installs apache 2 and development headers to compile passenger'
    task :install, :roles => :apache2 do
      puts 'Installing apache 2'
      utilities.apt_install %w[apache2 apache2.2-common apache2-mpm-prefork apache2-utils
        libexpat1 ssl-cert libapr1 libapr1-dev   libaprutil1 libmagic1
        libpcre3 libpq5 openssl apache2-prefork-dev]
      utilities.apt_install %w[libapache2-mod-php5  libdbd-mysql-perl libdbi-perl libmysqlclient-dev mysql-client
        libnet-daemon-perl libplrpc-perl libpq5 php5-common php5-mysql] if apache2_with_php
    end

  end
end
