Dir[File.join(File.dirname(__FILE__), 'provision/*.rb')].sort.each { |lib| require lib }
#TODO: setup a default watcher, plumb an :init as the base default instead of nil to be more declarative.