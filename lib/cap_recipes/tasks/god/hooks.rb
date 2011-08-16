Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "god:install"
  after "god:install", "god:setup"
  after "deploy:start", "god:restart"
  after "deploy:restart", "god:restart"
  before "god:start", "god:contacts"
  before "god:restart", "god:contacts"
end