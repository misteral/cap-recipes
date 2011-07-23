# If you require the TeeLogger then 
class TeeLogWriter
  def initialize
    @file=File.open(File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','log','deploy.log')), "w")
  end

  def puts(message)
    STDOUT.puts message
    @file.puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}"
  end

end

Capistrano::Configuration.instance(true).load do
  #replace the running logger device with our own.
  self.logger.instance_variable_set(:@device,TeeLogWriter.new)
end
