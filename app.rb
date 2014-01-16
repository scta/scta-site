# Sinatra example
#
# Call as http://localhost:4567/sparql?query=uri,
# where `uri` is the URI of a SPARQL query, or
# a URI-escaped SPARQL query, for example:
#   http://localhost:4567/?query=SELECT%20?s%20?p%20?o%20WHERE%20%7B?s%20?p%20?o%7D
require 'sinatra'
#require 'rdf'
require 'sparql'
require 'sinatra/sparql'
require 'uri'

get '/data' do
  queryable = RDF::Repository.load("/Users/JCWitt/Desktop/scta/lectio1.rdf")
  sse = SPARQL.parse("SELECT * WHERE { ?s ?p ?o }")
  sse.execute(queryable)
  # settings.sparql_options.replace(:standard_prefixes => true)
  # repository = RDF::Repository.new do |graph|
  #   graph << [RDF::Node.new, RDF::DC.title, "Hello, world!"]
  # end
  # if params["query"]
  #   query = params["query"].to_s.match(/^http:/) ? RDF::Util::File.open_file(params["query"]) : ::URI.decode(params["query"].to_s)
  #   SPARQL.execute(query, repository)
  # else
  #   settings.sparql_options.merge!(:prefixes => {
  #     :ssd => "http://www.w3.org/ns/sparql-service-description#",
  #     :void => "http://rdfs.org/ns/void#"
  #   })
  #   service_description(:repo => repository)
  # end

end

get '/' do
  erb :index
end