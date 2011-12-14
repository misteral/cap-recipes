Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "god:install"
  after "god:install", "god:setup"
  before "deploy:start", "god:setup"
  after "deploy:start", "god:start"
  before "deploy:restart", "god:setup"
  after "god:setup", "god:contacts", "god:restart"
end