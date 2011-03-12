# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do
  before "deploy:provision", "nginx_unicorn:install"
  before "deploy:setup", "nginx_unicorn:configure"
end
