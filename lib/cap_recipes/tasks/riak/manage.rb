Capistrano::Configuration.instance(true).load do
  namespace :riak do
    roles[:riak]
    %w(start stop restart ping force-reload).each do |t|
      desc "#{t} riak"
      task t.to_sym, :roles => :riak do
        sudo "/etc/init.d/riak #{t}"
      end
    end
  end
end