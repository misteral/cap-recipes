require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/manage')

Capistrano::Configuration.instance(true).load do
  set :mongodb_data_path, "/data/db"
  set :mongodb_bin_path, "/opt/mongo"
  
  namespace :mongodb do    
    desc "Installs mongodb binaries and all dependencies"
    task :install, :role => :app do
      #Package libboost1.37-dev has no installation candidate Target Ubuntu 10.04, changed to libboost-dev
      #ref http://www.mongodb.org/display/DOCS/Building+for+Linux
      utilities.apt_install "git-core tcsh scons g++ libpcre++-dev"
      utilities.apt_install "libboost-dev libreadline-dev xulrunner-dev"
      utilities.apt_install "libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-date-time-dev"
      mongodb.make_spidermonkey
      mongodb.make_mongodb
      mongodb.setup_db_path
    end

    task :make_spidermonkey, :role => :app do
      run "mkdir -p ~/tmp"
      run "cd ~/tmp; wget ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz"
      run "cd ~/tmp; tar -zxvf js-1.7.0.tar.gz"
      run "cd ~/tmp/js/src; export CFLAGS=\"-DJS_C_STRINGS_ARE_UTF8\""
      run "cd ~/tmp/js/src; #{sudo} make -f Makefile.ref"
      run "cd ~/tmp/js/src; #{sudo} JS_DIST=/usr make -f Makefile.ref export"
    end

    task :make_mongodb, :role => :app do
      sudo "rm -rf ~/tmp/mongo"
      run "cd ~/tmp; git clone git://github.com/mongodb/mongo.git"
      run "cd ~/tmp/mongo; #{sudo} scons all"
      run "cd ~/tmp/mongo; #{sudo} scons --prefix=#{mongodb_bin_path} install"
    end

    task :setup_db_path, :role => :app do
      sudo "mkdir -p #{mongodb_data_path}"
      mongodb.start
    end
  end
end
