# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :redis do
    roles[:redis] #make an empty role
    %w(start stop restart).each do |t|
      desc "#{t.capitalize} redis server"
      task t.to_sym, :roles => :redis do
        sudo "/etc/init.d/redis #{t}"
      end
    end
  end
end
