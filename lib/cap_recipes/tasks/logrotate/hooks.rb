# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  before "deploy:restart", "logrotate:rotate"
end
