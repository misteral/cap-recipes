# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "nginx_unicorn:install"
  after "deploy:setup", "nginx_unicorn:setup"
  after "logrotate:rotate", "nginx_unicorn:reopen"
  after "sdagent:setup", "nginx_unicorn:setup_sdagent"
  on :load, "nginx_unicorn:runner"
  
  before "nginx_unicorn:restart" do
    #if this runs too early it interferes with a new checkout of the app
    nginx_unicorn.ensure_system_log_location
  end

  after "nginx_unicorn:setup" do
    nginx_unicorn.remove_default
    nginx_unicorn.configure
    nginx_unicorn.restart
  end
end
