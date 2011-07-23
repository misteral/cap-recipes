require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/manage')

Capistrano::Configuration.instance(true).load do

  namespace :mongodb do
    roles[:mongod] # Mongo Database
    roles[:mongoc] # Mongo Config
    roles[:mongos] # Mongo Server
    roles[:mongoa] # Mongo Arbiter

    set :mongodb_data_path, "/data/db"  # Ignored when using packages
    set :mongodb_bin_path, "/opt/mongo" # Ignored when using packages

    set :mongodb_config, "/etc/mongodb.conf"
    set :mongodb_target, :upstart
    set :mongodb_install_from, :package

    task :install do
      if mongodb_install_from == :package
        install_from_package
      else
        install_from_source
      end
    end

    task :install_from_package, :roles => [:mongod,:mongoc,:mongos,:mongoa] do
      # http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages
      target = case mongodb_target
      when :sysvinit
        "deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen"
      when :upstart
        "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
      else
        raise Capistrano::Error, "Unknown mongodb_target"
      end

      put target,'/tmp/mongodb.list'
      sudo "mv /tmp/mongodb.list /etc/apt/sources.list.d/mongodb.list"
      sudo "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
      utilities.apt_upgrade
      utilities.apt_install "mongodb-10gen"
    end

    desc "Installs mongodb binaries and all dependencies"
    task :install_from_source, :roles => [:mongod,:mongoc,:mongos,:mongoa] do
      #Package libboost1.37-dev has no installation candidate Target Ubuntu 10.04, changed to libboost-dev
      #ref http://www.mongodb.org/display/DOCS/Building+for+Linux
      utilities.apt_install "git-core tcsh scons g++ libpcre++-dev"
      utilities.apt_install "libboost-dev libreadline-dev xulrunner-dev"
      utilities.apt_install "libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-date-time-dev"
      mongodb.make_spidermonkey
      mongodb.make_mongodb
      mongodb.setup_db_path
    end

    task :make_spidermonkey, :roles => [:mongod,:mongoc,:mongos,:mongoa] do
      run "mkdir -p ~/tmp"
      run "cd ~/tmp; wget ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz"
      run "cd ~/tmp; tar -zxvf js-1.7.0.tar.gz"
      run "cd ~/tmp/js/src; export CFLAGS=\"-DJS_C_STRINGS_ARE_UTF8\""
      run "cd ~/tmp/js/src; #{sudo} make -f Makefile.ref"
      run "cd ~/tmp/js/src; #{sudo} JS_DIST=/usr make -f Makefile.ref export"
    end

    task :make_mongodb, :roles => [:mongod,:mongoc,:mongos,:mongoa] do
      sudo "rm -rf ~/tmp/mongo"
      run "cd ~/tmp; git clone git://github.com/mongodb/mongo.git"
      run "cd ~/tmp/mongo; #{sudo} scons all"
      run "cd ~/tmp/mongo; #{sudo} scons --prefix=#{mongodb_bin_path} install"
    end

    task :setup_db_path, :roles => [:mongod,:mongoc,:mongos,:mongoa] do
      sudo "mkdir -p #{mongodb_data_path}"
      mongodb.start
    end
  end
end
