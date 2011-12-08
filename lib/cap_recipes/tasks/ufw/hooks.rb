# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "ufw:install"
  after "ufw:install", "ufw:setup"
  after "ufw:setup", "ufw:enable"
end