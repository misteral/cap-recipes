# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do

  before "deploy:provision", "nginx_passenger:install"
  before "deploy:setup", "nginx_passenger:configure"

end