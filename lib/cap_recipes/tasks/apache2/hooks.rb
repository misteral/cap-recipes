Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "apache2:install"
end