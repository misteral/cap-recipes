require File.expand_path(File.dirname(__FILE__) + '/../utilities')
require File.expand_path(File.dirname(__FILE__) + '/install')

Capistrano::Configuration.instance(true).load do

  namespace :redis do
    %w(start stop restart).each do |t|
      desc "#{t.capitalize} redis server"
      task t.to_sym, :role => :db do
        sudo "/etc/init.d/redis #{t}"
      end
    end
  end
end
