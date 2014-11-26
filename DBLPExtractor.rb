require 'rubygems'
require 'mechanize'
require 'crack'
require 'bibtex'

require_relative 'Logger'

def get_pub_type(hashed_node)
  return hashed_node["hit"]["info"]["type"]
end

def get_pub_key(hashed_node)
  return hashed_node["hit"]["id"]
end

def get_pub_title(hashed_node)
  title = hashed_node["hit"]["info"]["title"]
  return title.gsub(/\.[  ]*$/,"")
end

def get_pub_url(hashed_node)
  return hashed_node["hit"]["url"]
end

def get_pub_year(hashed_node)
  return hashed_node["hit"]["info"]["year"]
end

def get_pub_authors(hashed_node)
  authors = hashed_node["hit"]["info"]["authors"]["author"]
  if authors.class.to_s == "Array"
      author_field = authors.join(" and ").to_s
  else
      author_field = authors.to_s
  end
  return author_field
end

def node_to_hash(node)
    return Crack::XML.parse(node.to_s)
end

def bibentry_from_xml(node)
    
  hnode = node_to_hash(node)

    entry = BibTeX::Entry.new({
    :type => get_pub_type(hnode),
    :key => get_pub_key(hnode),
    #:address => hashed_result[""],
    #:abstract => hashed_result["abstract"],
    #:annote => hashed_result[""],
    :author => get_pub_authors(hnode),
    #:booktitle => hashed_result["pubtitle"],
    #:chapter => hashed_result[""],
    #:crossref => hashed_result[""],
    #:doi => hashed_result["doi"],
    #:edition => hashed_result[""],
    #:editor => hashed_result[""],
    #:eprint => hashed_result[""],
    #:howpublished => hashed_result[""],
    #:institution => hashed_result["affiliations"],
    #:isbn => hashed_result["isbn"],
    #:issn => hashed_result["issn"],
    #:journal => hashed_result["pubtitle"],
    #:keywords => keywordsAll,
    #:keywordsUser => keywordsUser,
    #:keywordsIndex => keywordsIndex,
    #:month => hashed_result[""],
    #:note => hashed_result[""],
    #:number => hashed_result["issue"],
    #:organization => hashed_result[""],
    #:pages => hashed_result["spage"].to_s + "--" + hashed_result["epage"].to_s,
    #:publisher => hashed_result["publisher"],
    #:school => hashed_result["affiliations"],
    #:series => hashed_result[""],
    :title => get_pub_title(hnode),
    :url => get_pub_url(hnode),
    #:volume => hashed_result["volume"],
    :year => get_pub_year(hnode),
    #:query => @query.to_s,
    :source => "DBLP"
  })

  return entry
end

def process_page_results(results)
  nodes = results.search("//hit")
  entries = []

  Logger.instance.log("NODES: " +  nodes.length.to_s)
  
  nodes.each do |node|  
    entry = bibentry_from_xml(node) 
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

if ARGV.size > 0
  input_file = ARGV[0]
  output_file = ARGV[1]
end

def parse_file(filename)
  return Nokogiri::XML(File.open(filename))
end

# open file
result_nodes = parse_file(input_file)
# search
entries = process_page_results(result_nodes)
puts(entries)
# populate
library = populate(entries)
# export
export(output_file, library)

