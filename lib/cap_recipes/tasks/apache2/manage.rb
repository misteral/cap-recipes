Capistrano::Configuration.instance(true).load do

  set :apache_init_path, "/etc/init.d/apache2"

  namespace :apache2 do

    desc "Stops the apache web server"
    task :stop, :roles => :apache2 do
      puts "Stopping the apache server"
      sudo "#{apache_init_path} stop"
    end

    desc "Starts the apache web server"
    task :start, :roles => :apache2 do
      puts "Starting the apache server"
      sudo "#{apache_init_path} start"
    end

    desc "Restarts the apache web server"
    task :restart, :roles => :apache2 do
      puts "Restarting the apache server"
      sudo "#{apache_init_path} restart"
    end

  end
end
