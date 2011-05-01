Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "munin:install"
end