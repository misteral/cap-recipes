Capistrano::Configuration.instance(true).load do
  before "deploy:provision", "ruby19:install"
  before "ruby19:install", "aptitude:updates"
end