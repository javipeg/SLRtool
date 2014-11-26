require_relative 'IE3Library'
require_relative 'ACMLibrary'

termfile = "terms"

if ARGV.size > 0
	termfile = ARGV[0]
	exportfile = ARGV[1]
	source = ARGV[2]
end


case source
when "IEEE"
	lib = IE3Library.new(termfile)
when "ACM"
	lib = ACMLibrary.new(termfile)
when "DBLP"
	resultsfile = termfile
	lib = DBLPExtractor.new(resultsfile)
else
	puts "Wrong digital library!"
end


puts "Opened term file: " + termfile

puts "Downlading references ..."
lib.populate
puts "References fetched: " + lib.size.to_s

if exportfile != nil
	puts "Exporting bibtex ... " + exportfile
	lib.export(exportfile)
else
	puts "Exporting bibtex ... "
	lib.export
end
puts "BibTex file: " + lib.bibname
