Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "riak:install"
  after "riak:install", "riak:start"
end