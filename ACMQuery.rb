
class ACMQuery

def initialize(termfilename)
  @terms_file_name = termfilename
  #@terms_file_name = "oneterm"
end

def compose_search_term(term)
  #sterm = 'Title:"' + term + '" OR Abstract:"' + term + '" OR Keyword:"' + term + '"'
  sterm = 'Title:"' + term + '" OR Abstract:"' + term + '"'
  return sterm
end

def query_title_abstract
  query = ""
  File.readlines(@terms_file_name).each { |term|
    sterm = compose_search_term(term.chomp)
    query = query + ' OR ' + sterm
  }
  return query[4..-1]
end

end

