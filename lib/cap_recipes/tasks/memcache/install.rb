require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  namespace :memcache do
    
    desc 'Installs memcache and the ruby gem'
    task :install, :roles => :app do
      puts 'Installing memcache'
      utilities.apt_install 'memcached'
      #TODO: Installing the GEM should be broken out into it's own task, This is not a safe default assumption.
      #      I may want to use RVM in production which means #1 I don't want this to happen at all, #2 the gem path will be
      #      wrong even if I do. #3 If we aren't deploying a ruby application but want memcached this becomes problematic.
      #      I suggest a preference which can be defaulted to true, as to not break existing deploy scripts, but will allow folks
      #      who don't want it, to set it to false in their deploy. It would be awesome to depricate the preference, so when true, it always
      #      outputs a deprication warning saying that it will be switched to not install next release.
      try_sudo "#{base_ruby_path}/bin/gem install memcache-client --no-ri --no-rdoc"
      memcache.start
    end
    
  end
end