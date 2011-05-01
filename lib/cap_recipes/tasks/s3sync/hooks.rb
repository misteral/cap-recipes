Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "s3sync:install"
end