# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do

  after "deploy:provision", "nginx_passenger:install"
  before "deploy:setup", "nginx_passenger:configure"

end