Capistrano::Configuration.instance(true).load do
  namespace :deploy do
    
    desc "Stops the phusion passenger server"
    task :stop, :roles => :app do
      puts "Stopping rails web server"
      apache.stop
    end

    desc "Starts the phusion passenger server"
    task :start, :roles => :app do
      puts "Starting rails web server"
      apache.start
    end

    desc "Restarts the phusion passenger server"
    task :restart, :roles => :app do
      puts "Restarting passenger by touching restart.txt"
      run "touch #{latest_release}/tmp/restart.txt"
    end
    
  end
end
