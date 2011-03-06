# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do

  #When using Rails setup unicorn http://unicorn.bogomips.org/ as a dependency in the Gemfile and include a config/unicorn.rb
  #TODO: This needs more testing and may not work properly yet.
  namespace :unicorn do

    set :rails_env, "production"

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