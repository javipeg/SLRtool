require 'rubygems'
require 'mechanize'
require 'crack'
require 'bibtex'
require 'csv'
require 'zlib'

require_relative 'Logger'

def get_pub_type(row)
  
  #puts hashed_node
  case get_field_as_nonempty(row, "type")
    when "Chapter"
      pubtype = :inproceedings
    when "Article"
      pubtype = :article
    else
      pubtype = :misc
  end

  return pubtype
end

def get_field_as_nonempty(row, key)
  field = row[1][key]
  field == nil ? "" : field
  return field
end


def get_pub_key(row)
  return row[0]
end

def get_pub_title(row)
  return get_field_as_nonempty(row, "title")
end

def get_pub_url(row)
  return get_field_as_nonempty(row, "url")
end

def get_pub_year(row)
  return get_field_as_nonempty(row, "year")
end

def get_pub_authors(row)
  @agent = Mechanize.new { |a|
    a.user_agent_alias = 'Mac Safari'
  }
  # get URL
  url = get_field_as_nonempty(row, "url")
  # fetch doc & navigate to authors
  node = @agent.get(url).search("//form[@id='getaccess-webshop']/input[@name='authors']")
  # extract 
  if node != nil && node.size > 0
    authors = node.attr("value").text.gsub(",", " and")
  else
    authors = ""
  end
  return authors
end


def get_pub_authors2(row)
  return get_field_as_nonempty(row, "authors")
end

def get_pub_abstract(row)
  # get URL
  url = get_field_as_nonempty(row, "url")
  # fetch doc
  @agent = Mechanize.new { |a|
    a.user_agent_alias = 'Mac Safari'
  }
  # navigate to abstract
  node = @agent.get(url).search("//div[@class='abstract-content formatted']/p")
  # extract abstract
  if node != nil
    #puts url
    #puts node
    abstract = node.text
  else
    abstract = ""
  end

  return abstract
end

def get_pub_doi(row)
  return get_field_as_nonempty(row, "doi")
end

def get_pub_book(row)
  return get_field_as_nonempty(row, "publication")
end

def get_pub_journal(row)
  return get_field_as_nonempty(row, "publication")
end

def get_pub_volume(row)
  return get_field_as_nonempty(row, "jvolume")
end

def get_pub_number(row)
  return get_field_as_nonempty(row, "jissue")
end

def node_to_hash(node)
    return node
end



def bibentry_from_result(result)
    
  #hnode = node_to_hash(node)

#  puts result[1]
 # puts result.class
    entry = BibTeX::Entry.new({
    :type => get_pub_type(result),
    :key => get_pub_key(result),
    #:address => hashed_result[""],
    :abstract => get_pub_abstract(result),
    #:annote => hashed_result[""],
    :author => get_pub_authors(result),
    :booktitle => get_pub_book(result),
    #:chapter => hashed_result[""],
    #:crossref => hashed_result[""],
    :doi => get_pub_doi(result),
    #:edition => hashed_result[""],
    #:editor => hashed_result[""],
    #:eprint => hashed_result[""],
    #:howpublished => hashed_result[""],
    #:institution => hashed_result["affiliations"],
    #:isbn => hashed_result["isbn"],
    #:issn => hashed_result["issn"],
    :journal => get_pub_book(result),
    #:keywords => keywordsAll,
    #:keywordsUser => keywordsUser,
    #:keywordsIndex => keywordsIndex,
    #:month => hashed_result[""],
    #:note => hashed_result[""],
    :number => get_pub_number(result),
    #:organization => hashed_result[""],
    #:pages => hashed_result["spage"].to_s + "--" + hashed_result["epage"].to_s,
    #:publisher => hashed_result["publisher"],
    #:school => hashed_result["affiliations"],
    #:series => hashed_result[""],
    :title => get_pub_title(result),
    :url => get_pub_url(result),
    :volume => get_pub_volume(result),
    :year => get_pub_year(result),
    #:query => @query.to_s,
    :source => "SpringerLink"
  })

  return entry
end

def process_page_results(results)
  entries = []

  Logger.instance.log("NODES: " +  results.length.to_s)
  
  results.each do |result|
    entry = bibentry_from_result(result)
    entries << entry
  end

  return entries
end

def populate(bibentries)
  index = 0

  library = BibTeX::Bibliography.new
  bibentries.each { |b|
    library << b
      index += 1
      Logger.instance.log("Entry: " + index.to_s)
  }
  return library
end

def export(filename, library)
  File.open(filename, 'w') { |file| file.write(library.to_s) }
end

def parse_file(filename)
  entries = {}

  keys=['title', 'publication', 'bookseries', 'jvolume', 'jissue', 'doi', 'authors', 'year', 'url', 'type']
  CSV.foreach(filename, :headers => keys, encoding: "utf-8") do |row|
    entries[Zlib.crc32(row.fields[0])] = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
  end
  # remove first row
  #entries = entries[1..-1]
  
  return entries.tap { |entry| entry.delete(1970925691) }
end

#input_file = "./springer/antipattern.csv"
#output_file = "./springer/antipattern.csv.bib"

#input_file = "./springer/bad+smell.csv"
#output_file = "./springer/bad+smell.bib"

if ARGV.size > 0
  input_file = ARGV[0]
  output_file = ARGV[1]
end

# open file
results = parse_file(input_file)
# search
entries = process_page_results(results)
# populate
library = populate(entries)
# export
export(output_file, library)

