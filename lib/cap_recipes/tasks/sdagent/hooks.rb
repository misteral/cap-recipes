Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "sdagent:install"
end