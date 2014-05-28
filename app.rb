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
require 'rdf/ntriples'

require_relative 'lib/metadata'

require 'pry'
#require 'ruby-debug-ide'
include RDF

prefixes = "
          PREFIX owl: <http://www.w3.org/2002/07/owl#>
          PREFIX dbpedia: <http://dbpedia.org/ontology/>
          PREFIX dcterms: <http://purl.org/dc/terms/>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX scta-rel: <http://scta.info/relations/>
          PREFIX scta-terms: <http://scta.info/terms/>
          PREFIX role: <http://www.loc.gov/loc.terms/relators/>
          PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
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

def URLConvert (url)
  url_hash = {}
  if url.to_str.include? 'http://scta.info'
    url_hash[:url_label] = url.parent.to_s
    url_hash[:url_base] = url.to_str.gsub(url.parent.to_s, '')
    url_hash[:url_link] = url.to_str.gsub('http://scta.info', '')

  elsif url.qname
    url_hash[:url_label] = url.qname[0].to_s + ":"
    url_hash[:url_base] = url.qname[1].to_s
    url_hash[:url_link] = url.to_str
  else
    url_hash[:url_label] = url.parent.to_s
    url_hash[:url_base] = url.to_str.gsub(url.parent.to_s, '')
    url_hash[:url_link] = url.to_str
  end
  return url_hash
end


get '/' do
  erb :index
end

get '/relations/:relation' do |relation| 
  query = "#{prefixes}

          SELECT ?p ?o
          {
          <http://scta.info/relations/#{relation}> ?p ?o  .
          
          }
          ORDER BY ?s
          "
          @result = rdf_query(query)
          erb :obj_pred_display

end


get '/scta' do 
 query = "#{prefixes}

          SELECT ?s ?o
          {
          ?s a <http://scta.info/commentary> .
          ?s <http://purl.org/dc/elements/1.1/title> ?o  .
          }
          ORDER BY ?s
          " 
        @category = 'commentary'
        @result = rdf_query(query)
           
          
          erb :subj_display
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

post '/sparqlquery' do

  query = "#{params[:query]}"
  query_display_simple(query)
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

          @result = rdf_query(query)
          @count = @result.count
          @title = @result.first[:o] # this works for now but doesn't seem like a great method since if the title ever ceased to the first triple in the query output this wouldn't work.


          erb :obj_pred_display
  
end
























