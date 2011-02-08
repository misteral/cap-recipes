# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do

  namespace :cassandra do

    %w(start stop restart).each do |t|
      desc "#{t} cassandra"
      task t.to_sym, :roles => :db do
        sudo "/etc/init.d/cassandra #{t}"
      end
    end

  end
end

