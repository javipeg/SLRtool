require 'bibtex'
require_relative 'BibMerger'

#!/usr/bin/env ruby

ARGV.each do|a|
  puts "Argument: #{a}"
end

lib1_filename = ARGV[0]
lib2_filename = ARGV[1]
merged_filename = ARGV[2]

bm = BibMerger.new

library = bm.merge(lib1_filename, lib2_filename)

puts "merged: " + library.size.to_s

File.open(merged_filename, 'w') { |file| file.write(library.to_s) }
