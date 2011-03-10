Dir[File.join(File.dirname(__FILE__), 's3fs/*.rb')].sort.each { |lib| require lib }
roles[:s3fs] #empty role