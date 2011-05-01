Capistrano::Configuration.instance(true).load do

  after "deploy:restart", "memcache:restart" # clear cache after updating code
  after "deploy:provision", "memcache:install"

end