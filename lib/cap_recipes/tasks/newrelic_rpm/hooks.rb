# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "newrelic_rpm:install"
  after "newrelic_rpm:install", "newrelic_rpm:setup"
  on :load, "newrelic_rpm:watcher"
end
