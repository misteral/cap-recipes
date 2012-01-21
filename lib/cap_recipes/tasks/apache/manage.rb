require File.expand_path(File.dirname(__FILE__) + '/settings')

Capistrano::Configuration.instance(true).load do

  namespace :apache do
    %w(start stop restart).each do |t|
      desc "#{t} the apache web server"
      task t.to_sym do
        utilities.with_role(apache_role) do
          puts "#{t}ing the apache server"
          sudo "#{apache_init_path} #{t}"
        end
      end
    end

  end
end
