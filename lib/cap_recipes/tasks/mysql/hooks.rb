Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "mysql:install"
end