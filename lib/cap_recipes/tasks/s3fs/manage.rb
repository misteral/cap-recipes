# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :s3fs do
    roles[:s3fs] #empty role

    %w(start stop).each do |t|
      desc "#{t} s3fs"
      task t.to_sym, :roles => :s3fs do
        sudo "/etc/init.d/s3fs-mount #{t}"
      end
    end

    desc "stop and prevent start of s3fs on all roles"
    task :uninstall do
      s3fs.stop
      utilities.run_compressed %Q{
        #{sudo} update-rc.d -f s3fs-mount remove;
        #{sudo} rm -rf /etc/init.d/s3fs-mount;
      }
    end
  end

end