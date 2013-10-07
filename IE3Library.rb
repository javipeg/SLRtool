#require 'rubygems'
#require 'mechanize'

require 'bibtex'

require_relative 'IE3Search'
require_relative 'Logger'

class IE3Library
	attr_reader :bibname

def initialize(termfilename)
	@search = IE3Search.new(termfilename)
	@filename = ""
end

def populate
	index = 0
	bibentries = @search.search

	@library = BibTeX::Bibliography.new
	bibentries.each { |b|
		@library << b
    	index += 1
    	Logger.instance.log("Entry: " + index.to_s)
	}
end

#def export
#	t = Time.now
#	@bibname = "IE3_" + t.strftime("%Y-%m-%d_%H-%M-%S") + ".bib"
#	File.open(@bibname, 'w') { |file| file.write(@library.to_s) }
#end

def export(filename)
	@bibname = filename
	File.open(filename, 'w') { |file| file.write(@library.to_s) }
end

def size
	return @library.size
end

end