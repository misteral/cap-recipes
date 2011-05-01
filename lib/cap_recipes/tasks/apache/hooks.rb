Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "apache:install"
end