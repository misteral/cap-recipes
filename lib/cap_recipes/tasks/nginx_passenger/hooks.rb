# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "nginx_passenger:install"
  after "deploy:setup", "nginx_passenger:configure"
  # you don't need to restart if you are using the regular capistrano timestamped deployes; I think.
  #after "deploy:restart", "nginx_passenger:passenger:restart"
  after "logrotate:rotate", "nginx_passenger:reopen"
  on :load, "nginx_passenger:watcher"
end