require 'rubygems'
require 'mechanize'
#require 'active_support' #if you have Rails installed
#require 'active_support/core_ext/hash'
require 'crack'
require 'bibtex'

require_relative 'IE3Query'
require_relative 'Logger'

class IE3Search

  attr_reader :maxresults
  attr_reader :firstresult
  
def initialize(termfilename)
  @query = IE3Query.new(termfilename).query_title_abstract
  #@query = IE3Query.new(termfilename).query_keywords
  #@query = IE3Query.new(termfilename).query_title_abstract_keywords
  #@query = IE3Query.new(termfilename).query_all_metadata

  @search_url = 'http://ieeexplore.ieee.org/gateway/ipsSearch.jsp'
  @agent = Mechanize.new { |a|
    a.user_agent_alias = 'Mac Safari'
  }
  @library = "IEEEXplore"

  @maxresults   = 500 
  @firstresult  = 1
end


def paper_id_from_link(plink)
 #method1: extracts 6789 from id=12345.6789& and id=6789&
 id = plink.scan(/id=[0-9\.]*&/).first.scan(/[0-9][0-9]+/).last

 #method2: extracts 12345.6789 from id=12345.6789& and 6789 from id=6789&
 #id = plink.scan(/id=[0-9\.]*&/).first[3..-2]

 #id = plink.scan(/id=[0-9\.]*&/)[4..-1]
 #id = plink[/id.*&/,1]
 #puts id
 #puts id.scan(/[0-9][0-9]+/).count
 #puts id.scan(/[0-9][0-9]+/).last
 #return plink[/id.*&/,1]

 return id
end



def bibentry_from_xml(node)
  #puts node
  hash_entry = {}
  hash_entry[:node] = node 
  #puts hash_entry
  
 #hashed_entry = Hash.from_xml(node)
  hashed_node = Crack::XML.parse(node.to_s)
  #puts hashed_entry
  hashed_result = hashed_node["document"]

  #puts hashed_result
  
  case hashed_result["pubtype"]
    when "Books & eBooks"
      pubtype = :book
    when "Conference Publications"
      pubtype = :inproceedings
    when "Early Access Articles"
      pubtype = :article
    when "Journals & Magazines"
      pubtype = :article
    else
      pubtype = :misc
  end
 
    if hashed_result["authors"] != nil
        author = hashed_result["authors"].gsub(";", " and ")
    else
        author = ""
    end

  keywords = []
  if hashed_result["controlledterms"] != nil
    keywordsC = []
    keywordsC = hashed_result["controlledterms"]["term"]
    #keywordsUser = keywordsC.join(",")
    #keywordsUser = keywordsC
    #keywords << keywordsC
    if keywordsC.class.to_s == "Array"
      keywordsUser = keywordsC.inspect.delete('"').delete("[").delete("]")
      keywordsUser = keywordsC.join(",")
      Logger.instance.log(keywordsUser)
    else
      keywordsUser = keywordsC.to_s
    end
  end
  if hashed_result["thesaurusterms"] != nil
    keywordsT = []
    keywordsT = hashed_result["thesaurusterms"]["term"]
    Logger.instance.log(keywordsT)
    Logger.instance.log("CLASS: " + keywordsT.class.to_s)
    if keywordsT.class.to_s == "Array"
      keywordsIndex = keywordsT.join(",")
    else
      keywordsIndex = keywordsT.to_s
    end
    #keywordsIndex = keywordsT.join(",")
    #keywordsIndex = keywordsT
    #keywords << keywordsT
  end
  #keywordsAll = (keywords.flatten) * ","
  
  entry = BibTeX::Entry.new({
    :type => pubtype,
    :key => hashed_result["arnumber"],

    :address => hashed_result[""],
    :abstract => hashed_result["abstract"],
    :annote => hashed_result[""],
    :author => author,
    :booktitle => hashed_result["pubtitle"],
    :chapter => hashed_result[""],
    :crossref => hashed_result[""],
    :doi => hashed_result["doi"],
    :edition => hashed_result[""],
    :editor => hashed_result[""],
    :eprint => hashed_result[""],
    :howpublished => hashed_result[""],
    :institution => hashed_result["affiliations"],
    :isbn => hashed_result["isbn"],
    :issn => hashed_result["issn"],
    :journal => hashed_result["pubtitle"],
    #:keywords => keywordsAll,
    :keywordsUser => keywordsUser,
    :keywordsIndex => keywordsIndex,
    :month => hashed_result[""],
    :note => hashed_result[""],
    :number => hashed_result["issue"],
    :organization => hashed_result[""],
    :pages => hashed_result["spage"].to_s + "--" + hashed_result["epage"].to_s,
    :publisher => hashed_result["publisher"],
    :school => hashed_result["affiliations"],
    :series => hashed_result[""],
    :title => hashed_result["title"],
    :url => hashed_result["mdurl"],
    :volume => hashed_result["volume"],
    :year => hashed_result["py"],
    :query => @query.to_s,
    :source => @library
  })

  return entry
end

def process_page_results(results)

  nodes = results.search("//document")
  entries = []

  Logger.instance.log("NODES: " +  nodes.length.to_s)
  
  nodes.each do |node|
    # puts link.text
    #puts link.href
    #id = paper_id_from_link(link.href)
    #puts "ID: " + id
    entry = bibentry_from_xml(node)
 
    #entry[:bibtex] = bibentry_from_xml(node)
 
    entries << entry
  end

  return entries
  #puts "PAPERS FOUND"
  #puts links.count
end

def bibentry_from_id(id)
  biburl = "http://dl.acm.org/exportformats.cfm?id=" + id + "&expformat=bibtex"
  bibpage = @agent.get(biburl)
  node = bibpage.at('pre')
  #puts node.count
  return node.text
  #pp bibpage
end

def abstract_from_id(id)
  paperurl = "http://dl.acm.org/citation.cfm?id=" + id + "&preflayout=flat"
  paperpage = @agent.get(paperurl)
  #node = paperpage.at("div[@id='abstract']")
  #puts paperurl
  #node = paperpage.at("div[@id='abstract']/div/div/p")
  #node = paperpage.search("//A[@NAME='abstract']")
  #node = paperpage.search("a[@name='abstract']")
  #node = paperpage.search("//div[preceding-sibling::h1[@name = 'abstract']/div/p")
  #node = paperpage.search("a[@name = 'abstract'] /div/p")
  node = paperpage.search("//div[preceding-sibling::h1[1][. = 'ABSTRACT']]/div")
  return node[0].text
  
  #puts node.count
  #node.each { |n|
  #  puts "NODE: " + id
  #  puts n.text
  #}

  #puts node
  #pp bibpage
end

def queryurl()
  # EXAMPLE
  # http://ieeexplore.ieee.org/gateway/ipsSearch.jsp?querytext=(%22Document%20Title%22:%22design%20smells%22%20OR%20%22Document%20Title%22:%22bad%20smells%22)&hc=100&rs=1&sortfield=py&sortorder=desc

  queryurl = @search_url  + "?" + "querytext=(" + @query + ")"  # base query
  queryurl = queryurl     + "&" + "hc=#{@maxresults}"           # max. number of results
  queryurl = queryurl     + "&" + "rs=#{@firstresult}"          # first result
  queryurl = queryurl     + "&" + "sortfield=py&sortorder=desc" # sort by year in descending order


  #queryurl = 'http://ieeexplore.ieee.org/gateway/ipsSearch.jsp?querytext=(("Document Title":"test selection" OR "Abstract":"test selection") AND ("Document Title":"tool" OR "Abstract":"tool" OR "Document Title":"plugin" OR "Abstract":"plugin" OR "Document Title":"extension" OR "Abstract":"extension"))'
  #@query = '("Document Title":"test selection" OR "Abstract":"test selection") AND ("Document Title":"tool" OR "Abstract":"tool" OR "Document Title":"plugin" OR "Abstract":"plugin" OR "Document Title":"extension" OR "Abstract":"extension")'
  return queryurl
end


def search()

  # Launch search

  results = @agent.get(queryurl)

  Logger.instance.log("Query URL: " + queryurl)
  bibentries = []

  # Process first page
  pagecount = 1
  results_number =  results.at("totalfound").text
  #puts results_number

  bibentries = process_page_results(results)
  
  #next_page_link = results.links_with(:text => %r{.*next}).last

  # Process remaining pages
  #while next_page_link != nil
  #  pagecount = pagecount + 1
  #  puts "Page: " + pagecount.to_s
    # puts next_page_link.href
  #  results = @agent.get(next_page_link.href)
  #  moreentries = process_page_results(results)
  #  bibentries.push(*moreentries)
  #  next_page_link = results.links_with(:text => %r{.*next}).last
    #puts results.links_with(:text => %r{.*next}).count
    #puts next_page_link
  #end

  #puts next_page_link.href

  #pp page

  Logger.instance.log("Total processed papers: " + bibentries.size.to_s)
  return bibentries
end

end




