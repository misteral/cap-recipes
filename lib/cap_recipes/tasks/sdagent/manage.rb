# @author Donovan Bray <donnoman@donovanbray.com>
require File.expand_path(File.dirname(__FILE__) + '/../utilities')


Capistrano::Configuration.instance(true).load do

  namespace :sdagent do
    %w(start stop restart).each do |t|
      desc "#{t.capitalize} serverdensity agent"
      task t.to_sym, :roles => :sdagent do
        sudo "/etc/init.d/sd-agent #{t}"
      end
    end
  end
end
