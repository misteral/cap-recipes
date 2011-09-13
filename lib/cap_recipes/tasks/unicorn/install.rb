require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  namespace :unicorn do

    set :unicorn_version, "4.0.1"
    set :unicorn_template_path, File.join(File.dirname(__FILE__),'unicorn.rb.template')
    set :unicorn_god_path, File.join(File.dirname(__FILE__),'unicorn.god')
    set(:unicorn_user) {user}
    set(:unicorn_group) {user}
    set :unicorn_workers, 3
    set :unicorn_backlog, 2048
    set :unicorn_tries, -1
    set :unicorn_timeout, 30
    set :unicorn_watcher, nil
    set :unicorn_suppress_runner, false
    set(:unicorn_root) {"#{deploy_to}/current"}
    
    desc "select watcher"
    task :watcher do
      unicorn.send("watch_with_#{unicorn_watcher}".to_sym) unless unicorn_watcher.nil?
    end

    desc "Use GOD as unicorn's runner"
    task :watch_with_god do
      #This is a test pattern, and may not be the best way to handle diverging
      #maintenance tasks based on which watcher is used but here goes:
      #rejigger the maintenance tasks to use god when god is in play
      %w(start stop restart).each do |t|
        task t.to_sym, :roles => :app do
          god.cmd "#{t} unicorn" unless unicorn_suppress_runner
        end
      end
      before "god:restart", "unicorn:setup_god"
    end

    desc 'Installs unicorn'
    task :install, :roles => :app do
      utilities.gem_install "unicorn", unicorn_version
    end

    desc "setup god to watch unicorn"
    task :setup_god, :roles => :app do
      god.upload unicorn_god_path, 'unicorn.god'
    end
    
    task :configure, :roles => :app do
      utilities.upload_template unicorn_template_path, "#{current_release}/config/unicorn.rb"
    end

    task :stop, :roles => :app do
      run "cd #{current_path} && kill -QUIT `cat tmp/pids/unicorn.pid`"
    end

    task :start, :roles => :app do
      run "cd #{current_path} && #{base_ruby_path}/bin/unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
    end

    desc "restart unicorn"
    task :restart, :roles => :web do
      run "cd #{current_path}; [ -f tmp/pids/unicorn.pid ] && kill -USR2 `cat tmp/pids/unicorn.pid` || #{base_ruby_path}/bin/unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
    end

  end
end