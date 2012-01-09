Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "ssh:install_issue"
end