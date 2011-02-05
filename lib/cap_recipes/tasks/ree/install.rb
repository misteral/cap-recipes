require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/../aptitude/manage')

Capistrano::Configuration.instance(true).load do

  namespace :ree do

    set :ree_ver, 'ruby-enterprise-1.8.7-2010.02'
    set :ree_src, "http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz"
    set :ree_pkg_name, "ruby-enterprise_1.8.7-2010.02_amd64_ubuntu8.04.deb"
    set :ree_pkg, "http://rubyforge.org/frs/download.php/71097/ruby-enterprise_1.8.7-2010.02_amd64_ubuntu8.04.deb"
    set :ree_path, '/opt/ruby-enterprise'
    set :ree_from_source, false #if for some reason you can't use the pkg, build it from source
    set :ree_seg_fixup, false # Set to true if your logs are full of 4gb seg fixups and building from source.
    set(:base_ruby_path) { ree_path } if ree_from_source

    desc "install ree"
    task :setup, :except => {:no_release => true} do
      utilities.apt_install %w[build-essential libssl-dev libmysqlclient15-dev libreadline5-dev wget]
      if ree_from_source
        setup_from_source
      else
        setup_from_package
      end
    end

    task :setup_from_source,  :except => {:no_release => true}  do
      #this task doesn't deal with path issues yet
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{ree_src} && #{sudo} tar xzf #{ree_ver}.tar.gz"
      # Get rid of the 4gb seg fixup errors
      # from: http://blog.pacharest.com/2009/08/a-bit-technical-nginx-passenger-4gb-seg-fixup/
      # http://groups.google.com/group/emm-ruby/browse_thread/thread/1b9beffe8fa694a7
      cmd = "/usr/local/src/#{ree_ver}/installer --auto #{ree_path}"
      cmd = "CFLAGS='-mno-tls-direct-seg-refs' CXXFLAGS='-mno-tls-direct-seg-refs' #{cmd}" if ree_seg_fixup
      sudo cmd
    end

    task :setup_from_package,  :except => {:no_release => true} do
      sudo "wget --tries=2 -c --directory-prefix=/usr/local/src --progress=bar:force #{ree_pkg}"
      sudo "dpkg -i /usr/local/src/#{ree_pkg_name}"
    end

    before "ree:setup", "aptitude:updates"
  end
end
