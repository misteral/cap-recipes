Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "mongodb:install"
end