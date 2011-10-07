Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "sdagent:install"
  on :load, "sdagent:watcher"
end