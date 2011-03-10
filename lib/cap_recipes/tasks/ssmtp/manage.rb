# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :ssmtp do
    roles[:ssmtp] #empty role
    
    %w(start stop restart).each do |t|
      desc "#{t.capitalize} ssmtp agent"
      task t.to_sym, :role => :ssmtp do
        sudo "/etc/init.d/ssmtp #{t}"
      end
    end
    
  end
end
