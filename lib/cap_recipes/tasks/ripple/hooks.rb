# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(true).load do
  after "deploy:update_code", "ripple:configure"
end
