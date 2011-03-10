# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  after "deploy:rollback:revision", "bundler:configure"
  after "deploy:update_code", "bundler:configure"
  after "deploy:provision", "bundler:install"
end