Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "god:install"
  after "god:install", "god:setup"
  after "deploy:start", "god:restart"
  before  "deploy:restart", "god:setup", "god:restart"
  before "god:start", "god:contacts"
  before "god:restart", "god:contacts"
end