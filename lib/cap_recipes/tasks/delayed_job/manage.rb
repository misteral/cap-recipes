require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do
  set :delayed_script_path, "#{current_path}/script/delayed_job"
  set :delayed_job_env, 'production'
  set :delayed_job_role, :app
  set :base_ruby_path,   '/usr'

  # TODO: I think the with_role pattern is broken, if you override delayed_job_role in your deploy.rb it's too late.
  # the task has been associated with :app at recipe load time. Thats probably why with_role was created so that the 
  # role could be re-evaluated at execution time making setting the role at load time meaningless. A better pattern 
  # that I've started elsewhere is to create an empty role and associate servers with the role which CAN happen at 
  # load time. See: riak as an example.  -- donnoman

  namespace :delayed_job do
    desc "Start delayed_job process"
    task :start, :roles => delayed_job_role do
      utilities.with_role(delayed_job_role) do
        try_sudo "RAILS_ENV=#{delayed_job_env} #{base_ruby_path}/bin/ruby #{delayed_script_path} start"
      end
    end

    desc "Stop delayed_job process"
    task :stop, :roles => delayed_job_role do
      utilities.with_role(delayed_job_role) do
        try_sudo "RAILS_ENV=#{delayed_job_env} #{base_ruby_path}/bin/ruby #{delayed_script_path} stop"
      end
    end

    desc "Restart delayed_job process"
    task :restart, :roles => delayed_job_role do
      utilities.with_role(delayed_job_role) do
        delayed_job.stop
        sleep(4)
        try_sudo "killall -s TERM delayed_job; true"
        delayed_job.start
      end
    end
  end
end
