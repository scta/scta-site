# Sinatra example
#
# Call as http://localhost:4567/sparql?query=uri,
# where `uri` is the URI of a SPARQL query, or
# a URI-escaped SPARQL query, for example:
#   http://localhost:4567/?query=SELECT%20?s%20?p%20?o%20WHERE%20%7B?s%20?p%20?o%7D
require 'sinatra'
require 'rdf'
require 'sparql'
require 'sinatra/sparql'
require 'uri'
require 'sparql/client'

prefixes = "
          PREFIX owl: <http://www.w3.org/2002/07/owl#>
          PREFIX dbpedia: <http://dbpedia.org/ontology/>
          PREFIX dcterms: <http://purl.org/dc/terms/>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX scta-rel: <http://scta.info/relations/>
          PREFIX role: <http://www.loc.gov/loc.terms/relators/>
          PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
          "

def rdf_query(query)
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  result = sparql.query(query)
  return result
end


def query_display_simple(query)
  result = rdf_query(query)
  result.each_solution do |solution|
  puts solution.inspect
  end
end


get '/' do
  erb :index
end

get '/scta' do 
 query = "#{prefixes}

          SELECT ?p ?o
          {
          <http://scta.info/scta> ?p ?o  .
          }
          ORDER BY ?p
          " 
  query_display_simple(query)
end

get '/search' do
  erb :search
end

get '/searchresults' do


  @post = "#{params[:search]}"
  @category = "#{params[:category]}"
  query = "#{prefixes}

          SELECT ?s ?o
          {

          ?s a <http://scta.info/#{@category}> .       
          ?s <http://purl.org/dc/elements/1.1/title> ?o  .
          FILTER (REGEX(STR(?o), '#{@post}', 'i')) .
          }
          ORDER BY ?s
          " 
  #query_display_simple(query)
          @result = rdf_query(query)
          erb :searchresults
end



get '/:category' do |category| 
  
  query = "#{prefixes}

          SELECT ?s ?o
          {
          ?s a <http://scta.info/#{category}> .
          ?s <http://purl.org/dc/elements/1.1/title> ?o  .
          }
          ORDER BY ?s
          " 
  #query_display_simple(query)
        @category = category
        @result = rdf_query(query)
           
          
          erb :subj_display
end

get '/:category/:id' do |category, id|

@category = category
@id = id                
@subjectid = "<http://scta.info/#{@category}/#{@id}>"
  query = "#{prefixes}

          SELECT ?p ?o
          {
          #{@subjectid} ?p ?o .
          }
          ORDER BY ?p
          " 
   query2 = "#{prefixes}

          SELECT ?title
          {
          #{@subjectid} <http://purl.org/dc/elements/1.1/title> ?title .
          }
          " 

          
          @result = rdf_query(query)
           @titleresult = rdf_query(query2)
          
          erb :obj_pred_display
  
end






















=begin
get '/items' do 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([:s, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://scta.info/item")]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/items/:itemname' do |itemname| 
  query = "#{prefixes}

        SELECT ?p ?o
          {
          <http://scta.info/items/#{itemname}> ?p ?o .
          }
          ORDER BY ?p
          "
      query_display_simple(query)

end

get '/items/:itemname/transcriptions' do |itemname| 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  p = RDF::URI.new("http://purl.org/dc/terms/isPartOf")
  o = RDF::URI.new("http://scta.info/items/#{itemname}")
  query = sparql.select.where([:s, p, o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/transcriptions/:itemname' do |itemname| 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([RDF::URI.new("http://scta.info/transcriptions/#{itemname}"), :p, :o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/transcriptions' do 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([:s, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://scta.info/transcription")]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/commentaries' do 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([:s, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://scta.info/commentary")]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/commentaries/:commentaryname' do |commentaryname| 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([RDF::URI.new("http://scta.info/commentaries/#{commentaryname}"), :p, :o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/commentaries/:commentaryname/items' do |commentaryname| 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  o = RDF::URI.new("http://scta.info/commentaries/#{commentaryname}")
  p = RDF::URI.new("http://purl.org/dc/terms/isPartOf")
  query = sparql.select.where([:s, p, o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

#needs a filter that only picks triples that are book type
get '/commentaries/:commentaryname/books' do |commentaryname| 
  query = "#{prefixes}
    
    SELECT ?s {
      ?s dcterms:isPartOf <http://scta.info/commentaries/#{commentaryname}> .
      ?s a <http://scta.info/book> .
    }
    ORDER BY ?s
    "
query_display_simple(query)
end

get '/commentaries/:commentaryname/books/:bookname' do |commentaryname, bookname| 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  s = RDF::URI.new("http://scta.info/books/#{bookname}")
  query = sparql.select.where([s, :p, :o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/commentaries/:commentaryname/books/:bookname/items' do |commentaryname, bookname| 
  query = "#{prefixes}

      SELECT ?s {
      ?s dcterms:isPartOf <http://scta.info/books/#{bookname}> .
      ?s a <http://scta.info/item> .
    }
    ORDER BY ?s
    "
  query_display_simple(query)
end

get '/commentaries/:commentaryname/books/:bookname/distinctions' do |commentaryname, bookname| 
  query = "#{prefixes}

      SELECT ?p {
      <http://scta.info/books/#{bookname}> dcterms:hasPart ?p .
      ?p a <http://scta.info/distinction> .
    }
    ORDER BY ?p
    "
  query_display_simple(query)
end

get '/commentaries/:commentaryname/books/:bookname/distinctions/:distinction' do |commentaryname, bookname, distinctionname| 
  query = "#{prefixes}

      SELECT ?p ?o {
      <http://scta.info/distinctions/#{distinctionname}> ?p ?o .
    }
        ORDER BY ?p
    "
  query_display_simple(query)
end

get '/commentaries/:commentaryname/books/:bookname/distinctions/:distinction/items' do |commentaryname, bookname, distinctionname| 
  query = "#{prefixes}

      SELECT ?s {
      ?s dcterms:isPartOf <http://scta.info/distinctions/#{distinctionname}> .
      ?s a <http://scta.info/item> .
    }
    ORDER BY ?s
    "
  query_display_simple(query)
end

get '/commentaries/:commentaryname/distinctions' do |commentaryname|
  query = "#{prefixes}

          SELECT ?s
          {
          ?s dcterms:isPartOf <http://scta.info/commentaries/#{commentaryname}> .
          ?s a <http://scta.info/distinction> .
          }
          ORDER BY ?s
          " 
  query_display_simple(query)

end

get '/books' do 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([:s, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://scta.info/book")]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/books/:bookname' do |bookname|
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  s = RDF::URI.new("http://scta.info/books/#{bookname}")
  query = sparql.select.where([s, :p, :o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/distinctions' do 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([:s, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://scta.info/distinction")]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/distinctions/:distname' do |distname|
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  s = RDF::URI.new("http://scta.info/distinctions/#{distname}")
  query = sparql.select.where([s, :p, :o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/names/:itemname' do |itemname| 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([RDF::URI.new("http://scta.info/names/#{itemname}"), :p, :o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

get '/names' do 
  sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  query = sparql.select.where([:s, RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI.new("http://scta.info/name")]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
end
end

#old code to be deleted
sparql = SPARQL::Client.new("http://localhost:3030/ds/query")
  s = RDF::URI.new("http://scta.info/scta")
  query = sparql.select.where([:s, :p, :o]).limit(1000)
  query.each_solution do |solution|
  puts solution.inspect
=end







