require 'bibtex'

require_relative 'EntryMerger'

class BibMerger
    

def initialize()
    @emerger = EntryMerger.new()
end

def open_bib(bibfile)
    return BibTeX.open(bibfile)
end

def is_duplicate(e1, e2)    
    same_title = e1.title.gsub(/\s+/,'').downcase == e2.title.gsub(/\s+/,'').downcase  
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

def is_in?(library, entry)
    found = false
    
    dup = find_duplicate(library, entry)
    if dup != nil
       found = true
    end
    
    return found
end

def find_duplicate(library, duplicate)
    found = false
    
    ldup = nil

    library.each do |l|
        if is_duplicate(l, duplicate) && !found
            ldup = l
            found = true
        end
    end
    
    return ldup
end
    
def merge_entry(e1, e2)
    return @emerger.merge_entries(e1,e2)
end

def merge_library(lib1, lib2)

    bib1 = open_bib lib1
    bib2 = open_bib lib2
    
    duplicates = BibTeX::Bibliography.new()
    joined = bib1
    puts "size 1: " + joined.size.to_s
    puts "size 2: " + bib2.size.to_s


    #find duplicates
    bib2.each do | e2 |
        duplicated = false
        bib1.each do | e1 |
            #puts ("Iterating: " + e1.title + ", " + e2.title)
            if is_duplicate(e1, e2) && !is_in?(duplicates, e2)
                duplicates << e2
                #puts "found dup: " + e2.key
            end
        end
    end

    puts "dupes:  " + duplicates.size.to_s

    # add non-duplicates
    bib2.each do | e2 |
        if !is_in?(duplicates, e2)
            joined << e2
            #puts "non-dup added to joined: " + e2.key
            #puts "non-dupe: " + e2.title
        end
    end
    
    # merge duplicates
    duplicates.each do |d|
        e = find_duplicate(joined, d)
        joined.delete(e)
        joined << merge_entry(e, d) # check!
        #puts "dup merged to joined: " + e.key
         # check!
    end
    
    return joined
end

def merge(lib1, lib2)
    merge_library(lib1,lib2)
end

end