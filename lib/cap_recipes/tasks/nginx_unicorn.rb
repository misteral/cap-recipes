Dir[File.join(File.dirname(__FILE__), 'nginx_unicorn/*.rb')].sort.each { |lib| require lib }
