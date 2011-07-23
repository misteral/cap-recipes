Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "erlang:install"
end