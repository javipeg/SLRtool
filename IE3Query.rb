class IE3Query

	attr_reader :last_query

def initialize(termfilename)
  @terms_file_name = termfilename
  #@terms_file_name = "oneterm"
end

def compose_search_term_ta(term)
  #sterm = '"Document Title":"' + term + '" OR "Abstract":"' + term + '" OR "Keyword":"' + term + '"'
  sterm = '"Document Title":"%{t}" OR "Abstract":"%{t}"    ' % {t: term}

  return sterm
end

def query_title_abstract
  query = ""
  File.readlines(@terms_file_name).each { |term|
    sterm = compose_search_term_ta(term.chomp)
    query = query + ' OR ' + sterm
  }
  
  @last_query = query[4..-1]
  return @last_query
end


def compose_search_term_tak(term)
  #sterm = '"Document Title":"' + term + '" OR "Abstract":"' + term + '" OR "Keyword":"' + term + '"'
  sterm = '"Document Title":"%{t}" OR "Abstract":"%{t}" OR "Thesaurus Terms":"%{t}" OR "Inspec Controlled Terms":"%{t}" OR "Search Index Terms":"%{t}"' % {t: term}

  return sterm
end

def query_title_abstract_keywords
  query = ""
  File.readlines(@terms_file_name).each { |term|
    sterm = compose_search_term_tak(term.chomp)
    query = query + ' OR ' + sterm
  }
  
  @last_query = query[4..-1]
  return @last_query
end


def compose_search_term_k(term)
  #sterm = '"Document Title":"' + term + '" OR "Abstract":"' + term + '" OR "Keyword":"' + term + '"'
  sterm = '"Thesaurus Terms":"%{t}" OR "Inspec Controlled Terms":"%{t}" OR "Search Index Terms":"%{t}"' % {t: term}

  return sterm
end

def query_keywords
  query = ""
  File.readlines(@terms_file_name).each { |term|
    sterm = compose_search_term_k(term.chomp)
    query = query + ' OR ' + sterm
  }
  
  @last_query = query[4..-1]
  return @last_query
end


def query_all_metadata
  query = ""
  File.readlines(@terms_file_name).each { |term|
    sterm = '"' + term.chomp + '"'
    query = query + ' OR ' + sterm
  }

  @last_query = query[4..-1]
  return @last_query
end

def to_s
	return @last_query
end

end
