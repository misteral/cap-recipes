# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  after "deploy:update_code", "resque:configure"
  before "deploy", "resque:workers:stop"
  after "deploy:restart", "resque:workers:start"
  after "deploy:start", "resque:workers:start"
  on :load, "resque:watcher"
end
