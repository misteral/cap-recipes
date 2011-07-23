require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/../aptitude/manage')

Capistrano::Configuration.instance(true).load do

  namespace :ruby19 do

    set :ruby_ver, 'ruby-1.9.2-p180'
    set(:ruby_src){"ftp://ftp.ruby-lang.org/pub/ruby/1.9/#{ruby_ver}.tar.bz2"}
    set :base_ruby_path, '/usr'

    desc "install ruby"
    task :install, :roles => :app do
      utilities.apt_install %w[build-essential zlib1g-dev libssl-dev openssl libcurl4-openssl-dev libreadline6-dev bzip2]
      sudo "mkdir -p /usr/local/src"
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{ruby_src} && #{sudo} rm -f #{ruby_ver}.tar && #{sudo} bunzip2 #{ruby_ver}.tar.bz2 && #{sudo} tar xvf #{ruby_ver}.tar"
      run "cd /usr/local/src/#{ruby_ver} && #{sudo} ./configure --prefix=#{base_ruby_path} --enable-shared && #{sudo} make install"
    end

    before "ruby:install", "aptitude:updates"

  end
end
