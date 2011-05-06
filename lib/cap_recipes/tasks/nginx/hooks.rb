# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do
  
  after "deploy:provision", "nginx:install"
  before "deploy:setup", "nginx:configure"
  
end