Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "riak:install"
  # The pattern for watchers is to only populate on a restart
  # that allows a deploy:cold to finish without starting procs
  # that you may not want started immediately.
  before "monit:restart", "riak:setup_monit"
  after "god:setup", "riak:setup_god"
end