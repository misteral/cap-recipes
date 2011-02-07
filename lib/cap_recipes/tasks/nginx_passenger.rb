Dir[File.join(File.dirname(__FILE__), 'nginx_passenger/*.rb')].sort.each { |lib| require lib }
