Dir[File.join(File.dirname(__FILE__), 'statsd/*.rb')].sort.each { |lib| require lib }
