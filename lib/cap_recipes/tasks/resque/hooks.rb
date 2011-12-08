# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  after "deploy:update_code", "resque:configure"
  on :load, "resque:watcher"
end
