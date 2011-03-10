Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "s3fs:install"
end