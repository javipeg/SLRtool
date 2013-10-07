#require 'rubygems'
#require 'mechanize'
require 'bibtex'

require_relative 'ACMSearch'
require_relative 'Logger'

class ACMLibrary
	attr_reader :bibname

def initialize(termfilename)
	@search = ACMSearch.new(termfilename)
	@filename = ""
end

def populate
	index = 0
	bibentries = @search.search
	Logger.instance.log("ACM bib size:: " + bibentries.size.to_s)

	@library = BibTeX::Bibliography.new
	bibentries.each { |b|

		if index != 49  # ad-hoc hack to get rid of a problem result of a particular query, TO REMOVE
		minilib = BibTeX.parse(b[:bibtex])

		puts "Last parsed: " + index.to_s
    	minilib[0][:abstract] = b[:abstract]
    	minilib[0].add(:query => @search.query)
    	minilib[0].add(:source => @search.library)
		
		#library << BibTeX::Entry.new(minilib[0])
		@library << minilib[0]
		end
	
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
