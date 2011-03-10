Capistrano::Configuration.instance(true).load do  
  after "deploy:provision" , "ree:install"
end