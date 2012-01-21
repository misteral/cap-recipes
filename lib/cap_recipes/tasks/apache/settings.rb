require File.expand_path(File.dirname(__FILE__) + '/../utilities')

Capistrano::Configuration.instance(true).load do

  namespace :apache do
    set :apache_with_php, true
    #TODO: this should really be :app but the previous recipe targeted web so we need
    #      to depreciate it somehow if we want to change it.
    set :apache_role, :web
    set :apache_init_path, "/etc/init.d/apache2"
  end

end
