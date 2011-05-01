Capistrano::Configuration.instance(true).load do
  after "deploy:provision", "rubygems:setup"
end