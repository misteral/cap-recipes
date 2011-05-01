Capistrano::Configuration.instance(true).load do  
  after "deploy:provision", "cassandra:install"
end