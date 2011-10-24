# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do

  after "deploy:provision", "nginx_passenger:install"
  after "deploy:setup", "nginx_passenger:configure"
  after "deploy:restart", "nginx_passenger:passenger:restart"
  on :load, "nginx_passenger:watcher"

end