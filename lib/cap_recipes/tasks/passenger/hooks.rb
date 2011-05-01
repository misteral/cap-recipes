Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "passenger:install"
end