Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "riak:install"
  after "riak:install", "riak:start"
  # The pattern for watchers is to only populate on a restart
  # that allows a deploy:cold to finish without starting procs 
  # that you may not want started immediately.
  before "monit:restart", "riak:setup_monit"
  before "god:restart", "riak:setup_god"
end