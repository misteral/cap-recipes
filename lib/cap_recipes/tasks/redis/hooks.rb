Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "redis:install"
end