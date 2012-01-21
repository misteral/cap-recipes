require File.expand_path(File.dirname(__FILE__) + '/settings')

Capistrano::Configuration.instance(true).load do

  namespace :apache do

    desc 'Installs apache and development headers to compile passenger'
    task :install do
      utilities.with_role(apache_role) do
        utilities.apt_install %w[apache apache.2-common apache-mpm-prefork apache-utils
          libexpat1 ssl-cert libapr1 libapr1-dev   libaprutil1 libmagic1
          libpcre3 libpq5 openssl apache-prefork-dev]
        utilities.apt_install %w[libapache-mod-php5  libdbd-mysql-perl libdbi-perl libmysqlclient-dev mysql-client
          libnet-daemon-perl libplrpc-perl libpq5 php5-common php5-mysql] if apache_with_php
      end
    end

  end
end
