# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :postfix do
    roles[:postfix] #empty role
    %w(start stop restart).each do |t|
      desc "#{t} Postfix"
      task t.to_sym, :roles => :postfix do
       sudo "/etc/init.d/postfix #{t}"
      end
    end

  end
end
