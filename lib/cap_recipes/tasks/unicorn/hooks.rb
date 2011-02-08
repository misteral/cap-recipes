# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  after "deploy:start",   "unicorn:start"
  after "deploy:stop",    "unicorn:stop"
  after "deploy:restart", "unicorn:restart"
end
