# @author Donovan Bray <donnoman@donovanbray.com>

Capistrano::Configuration.instance(true).load do

   before "deploy:start", "nginx_passenger:configure"
   before "deploy:restart", "nginx_passenger:configure"
   
 end