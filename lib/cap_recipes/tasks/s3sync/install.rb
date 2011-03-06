# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :s3sync do

    set :s3sync_ver, 's3sync'
    set :s3sync_src, "http://s3.amazonaws.com/ServEdge_pub/s3sync/s3sync.tar.gz"
    set :s3sync_path, "/usr/s3sync"
    set(:s3sync_config_path) { File.join(File.dirname(__FILE__),'s3config.yml')}
    set :s3sync_config_remote_path, '/etc/s3conf'
    set(:aws_access_key_id) { utilities.ask('What is the AWS_ACCESS_KEY_ID?','')}
    set(:aws_secret_access_key) {utilities.ask('What is the AWS_SECRET_ACCESS_KEY?','')}

    desc "install s3sync"
    task :install do
      sudo "rm -rf #{s3sync_path}"
      run "cd /usr/src && #{sudo} wget --tries=2 -c --progress=bar:force #{s3sync_src} && #{sudo} tar xzf #{s3sync_ver}.tar.gz"
      sudo "cp -r /usr/src/#{s3sync_ver} #{s3sync_path}"
      sudo "ln -sf #{s3sync_path}/*.rb /usr/bin/"
      setup
      verify
    end

    desc "setup s3sync"
    task :setup do
      sudo "mkdir -p #{s3sync_config_remote_path}"
      utilities.sudo_upload_template s3sync_config_path, "#{s3sync_config_remote_path}/s3config.yml", :mode => '600'
    end
    
    desc "verify s3sync works"
    task :verify do
      run "s3cmd.rb listbuckets"
    end

  end
end