require 'singleton'
 
class Logger
  include Singleton

def initialize
	@logfilename = "SLR.log"
	@logfile = File.open(@logfilename, "a")
end

def log(message)
	t = Time.now
	@logfile.puts(t.strftime("%Y.%m.%d;%H:%M:%S") + " > " + message.to_s)
end

end

