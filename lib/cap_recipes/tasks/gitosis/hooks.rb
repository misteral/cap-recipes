Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "gitosis:install"
end