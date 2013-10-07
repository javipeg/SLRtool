require 'rubygems'
require 'mechanize'

require_relative 'ACMQuery'
require_relative 'Wait'

class ACMSearch

  attr_reader :maxresults   # NOT USED HERE
  attr_reader :firstresult  # NOT USED HERE
  attr_reader :query
  attr_reader :library


def initialize(termfilename)
  @query = ACMQuery.new(termfilename).query_title_abstract
  #@query = IE3Query.new(termfilename).query_title_abstract
  
  @library = "ACM-DL"

  @search_url = 'http://dl.acm.org/results.cfm'
  @agent = Mechanize.new { |a|
    a.user_agent_alias = 'Mac Safari'
  }

  @maxresults   = 500
  @maxpages     = 10 # 20 per page
  @firstresult  = 1 # 21, 41, 61 ..., 161 
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


def process_page_results(results)
  links = results.links
  links = results.links_with(:href => %r{.*citation\.cfm.*})

  entries = []

  links.each do |link|
    # puts link.text
    #puts link.href
    Wait.new
    id = paper_id_from_link(link.href)
    puts "ID: " + id
                 
    entry = {}
    entry[:bibtex]   = bibentry_from_id(id)
    entry[:abstract] = abstract_from_id(id)

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

  #@query = '(Title:"test selection" OR Abstract:"test selection") AND (Title:"tool" OR Abstract:"tool" OR Title:"plugin" OR Abstract:"plugin" OR Title:"extension" OR Abstract:"extension")'
 

  #queryurl = @acm_search_url + "?" + "within=" + @query
  #queryurl = @acm_search_url + "?" + "query=" + @query + "&" + "querydisp=" + @query + "&" + "source_query=" + @query
  queryurl = @search_url + "?" + "query=" + @query + "&" + "querydisp=" + @query
  #queryurl = @acm_search_url + "?" + "query=" + @query + "&" + "source_query=" + @query
  #queryurl = @acm_search_url + "?" + "querydisp=" + @query + "&" + "source_query=" + @query
  #queryurl = @acm_search_url + "?" + "query=" + @query
  #queryurl = @acm_search_url + "?" + "querydisp=" + @query
  #queryurl = @acm_search_url + "?" + "source_query=" + @query
  queryurl = queryurl + "&" + "start=" + @firstresult.to_s
  queryurl = queryurl + "&" + "srt=meta%5Fpublished%5Fdate%20dsc"
  #queryurl = queryurl + "&" + "short=1"
  queryurl = queryurl + "&" + "coll=DL"
  queryurl = queryurl + "&" + "dl=GUIDE"
  queryurl = queryurl + "&" + "termshow=matchboolean"
  queryurl = queryurl + "&" + "zadv=1"
  #queryurl = queryurl + "&" + "since_year=1996"
  #queryurl = queryurl + "&" + "CFID=231504101&CFTOKEN=11710593"

  return queryurl
end


def search()

  # Launch search
  puts "Query URL: " + queryurl
  results = @agent.get(queryurl)
  bibentries = []

  # Process first page
  pagecount = 1
  bibentries = process_page_results(results)
  next_page_link = results.links_with(:text => %r{.*next}).last

  # Process remaining pages
  while next_page_link != nil && pagecount < @maxpages 
    pagecount = pagecount + 1
    puts "Page: " + pagecount.to_s
    # puts next_page_link.href
    results = @agent.get(next_page_link.href)
    moreentries = process_page_results(results)
    bibentries.push(*moreentries)
    next_page_link = results.links_with(:text => %r{.*next}).last
    #puts results.links_with(:text => %r{.*next}).count
    #puts next_page_link
  end

  #puts next_page_link.href

  #pp page

  return bibentries
end

#url2 = 'http://dl.acm.org/advsearch.cfm?coll=DL&dl=GUIDE&query=%28asd%29&qrycnt=2384&since_month=&since_year=&before_month=&before_year=&CFID=225416961&CFTOKEN=81957362'

end


