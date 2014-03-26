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

require_relative 'lib/metadata'

require 'pry'

prefixes = "
          PREFIX owl: <http://www.w3.org/2002/07/owl#>
          PREFIX dbpedia: <http://dbpedia.org/ontology/>
          PREFIX dcterms: <http://purl.org/dc/terms/>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX scta-rel: <http://scta.info/relations/>
          PREFIX scta-terms: <http://scta.info/terms/>
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

get '/test' do

  query = "#{prefixes}

          SELECT ?s
          {
          ?s <http://purl.org/dc/terms/hasPart>  <http://scta.info/transcriptions/reims_lectio1> .
          }
          "



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
          
          @result = rdf_query(query).map do |item|
            Metadata.new(item)
            
          end

          @result.sort_by(&:predicate_position)

          titleresult = @result.find do |item|
            item.predicate_with_prefix == "dc:title"
          end

          

          @title = titleresult.object

          erb :obj_pred_display
  
end
























