# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  after "deploy:provision" , "haproxy:install"
  after "haproxy:install", "haproxy:setup"
  after "haproxy:setup", "haproxy:enable"
  on :load, "haproxy:runner"
end
