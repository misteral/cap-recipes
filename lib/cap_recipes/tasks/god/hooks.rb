Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "god:install"
  after "god:install", "god:setup"
  before "deploy:restart", "god:restart"
  before "god:start", "god:contacts"
  before "god:restart", "god:contacts"
end