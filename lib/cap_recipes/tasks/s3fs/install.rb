# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :s3fs do

    set :s3fs_ver, 's3fs-1.40'
    set :s3fs_src, "http://s3fs.googlecode.com/files/s3fs-1.40.tar.gz"
    set :s3fs_path, "/opt/s3fs"
    set(:s3fs_mount_path) { File.join(File.dirname(__FILE__),'s3fs-mount')}
    set(:aws_access_key_id) { utilities.ask('What is the AWS_ACCESS_KEY_ID?','')}
    set(:aws_secret_access_key) { utilities.ask('What is the AWS_SECRET_ACCESS_KEY?','')}
    set(:s3fs_password) {"#{aws_access_key_id}:#{aws_secret_access_key}"}
    set :s3fs_volumes, [] #use add_s3fs_volume
    
    # add_s3fs_volume "backups", "/backups"
    # add_s3fs_volume "ads", "/ads", "-o default_acl=public-read -o allow_other"
    def add_s3fs_volume(bucket,mount,options=nil)
      s3fs_volumes << { :bucket => bucket, :mount => mount, :options => options }
    end

    desc "install s3fs"
    task :install do
      utilities.apt_install "build-essential libcurl4-openssl-dev pkg-config libxml2-dev libfuse2 libfuse-dev fuse-utils mime-support"
      sudo "mkdir -p #{s3fs_path}"
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{s3fs_src} && #{sudo} tar xzf #{s3fs_ver}.tar.gz"
      run "cd /usr/local/src/#{s3fs_ver} && #{sudo} ./configure --prefix=#{s3fs_path}"
      sudo "/etc/init.d/s3fs stop;true" #if it's a re-install attempt to stop, but don't block.
      run "cd /usr/local/src/#{s3fs_ver} && #{sudo} make && #{sudo} make install"
      setup
      start
    end

    desc "setup s3fs"
    task :setup, :role => :db do
      sudo "mkdir -p /backups /ads"
      begin
        put s3fs_password, 'passwd-s3fs', :mode => '640'
        sudo "mv passwd-s3fs /etc/passwd-s3fs"
      ensure
        run "rm passwd-s3fs;true"
      end
      utilities.sudo_upload_template s3fs_mount_path, '/etc/init.d/s3fs-mount', :mode => 'u+x'
      sudo "update-rc.d s3fs-mount defaults"
    end
    
    %w(start stop).each do |t|
      desc "#{t} s3fs"
      task t.to_sym do
        sudo "/etc/init.d/s3fs-mount #{t}"
      end
    end
  end
end