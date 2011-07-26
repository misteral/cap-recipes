Capistrano::Configuration.instance(true).load do
  before "deploy:provision", "ruby19:install"
end