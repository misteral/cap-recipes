Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "sdagent:install"
  before "god:install", "sdagent:install" #handle the sdagent dependency otherwise god may be unable to start.
  on :load, "sdagent:watcher"
end