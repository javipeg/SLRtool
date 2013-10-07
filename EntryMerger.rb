require 'bibtex'


class EntryMerger


def is_duplicate(p1, p2)

	same_title = e1.title.gsub(/\+s/,'').downcase == e2.title.gsub(/\+s/,'').downcase  
	same_year = e1.year == e2.year

	#puts "e1:" + e1.title.gsub(/\s+/,'').downcase
	#puts "e2:" + e2.title.gsub(/\s+/,'').downcase
	
	if same_title and same_year
		same_entry = true
		#puts "duplicate!" + e1.title
	else
		same_entry = false
	end

	return same_entry
	#return false
end

def is_in?(entry, key)
	return entry.key?(kvpair.key)
end

def find_duplicate(entry, kvpair)

    return entry.key?(kvpair.key)
end


def merge_entries(e1, e2)
    #return e1.merge(e2, filter=[:source, :query])
    #return e1.merge(e2)
    return e1
end
   

def merge_entries2(e1, e2)

	merged = BibTeX::Entry.new


    #return e1.merge(e2, filter=[:source, :query])
    #return e1.merge(e2)
    return e1
end

    #alias :merge_entries :merge
    
end