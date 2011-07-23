Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "ruby19:install"
end