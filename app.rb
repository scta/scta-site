# Sinatra example
#
# Call as http://localhost:4567/sparql?query=uri,
# where `uri` is the URI of a SPARQL query, or
# a URI-escaped SPARQL query, for example:
#   http://localhost:4567/?query=SELECT%20?s%20?p%20?o%20WHERE%20%7B?s%20?p%20?o%7D
require 'sinatra'
require 'bundler/setup'
require 'rdf'
require 'sparql'
require 'sinatra/sparql'
require 'uri'
require 'sparql/client'
require 'rdf/ntriples'
require 'cgi'
require 'equivalent-xml'
require 'open-uri'
require 'httparty'
require 'json'
require 'lbp'
if ENV['development']
  require 'pry'
end
 

require_relative 'lib/queries'
require_relative 'lib/custom_functions'

configure do
  set :protection, except: [:frame_options]
  set :root, File.dirname(__FILE__)

  # this added in attempt to "forbidden" response when clicking on links 
  set :protection, :except => :ip_spoofing
  set :protection, :except => :json
end



prefixes = "
          PREFIX owl: <http://www.w3.org/2002/07/owl#>
          PREFIX dbpedia: <http://dbpedia.org/ontology/>
          PREFIX dcterms: <http://purl.org/dc/terms/>
          PREFIX dc: <http://purl.org/dc/elements/1.1/>
          PREFIX sctap: <http://scta.info/property/>
          PREFIX sctar: <http://scta.info/resource/>
          PREFIX sctat: <http://scta.info/text/>
          PREFIX role: <http://www.loc.gov/loc.terms/relators/>
          PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          "





# def rdf_query(query)
  
#   if ENV['RACK_ENV'] == "production"
#     sparqlendpoint = "http://sparql.scta.info/ds/query"
#   elsif ENV['SPARQL'] == "local"
#     sparqlendpoint = "http://localhost:3030/ds/query"
#   else
#     sparqlendpoint = "http://sparql.scta.info/ds/query"
#   end
  
#   sparql = SPARQL::Client.new(sparqlendpoint)
#   result = sparql.query(query)

#   return result
# end


def query_display_simple(query)
  query_obj = Lbp::Query.new()
  result = query_obj.query(query)
  #result = rdf_query(query)
  result.each_solution do |solution|
  puts solution.inspect
  end
end

def URLConvert (url)
  url_hash = {}
  if url.class.to_s == "RDF::Node"
    url_hash[:url_label] = url.to_s
    url_hash[:url_base] = url.to_s
    url_hash[:url_link] = url.to_s
  elsif url.to_s.include? 'http://scta.info'
    url_hash[:url_label] = url.parent.to_s
    url_hash[:url_base] = url.to_s.gsub(url.parent.to_s, '')
    url_hash[:url_link] = url.to_s.gsub('http://scta.info', '')
  elsif url.qname
    url_hash[:url_label] = url.qname[0].to_s + ":"
    url_hash[:url_base] = url.qname[1].to_s
    url_hash[:url_link] = url.to_s
  else
    url_hash[:url_label] = url.parent.to_s
    url_hash[:url_base] = url.to_s.gsub(url.parent.to_s, '')
    url_hash[:url_link] = url.to_s
  end
  return url_hash
end


get '/' do
  quotationquery = "#{prefixes}

          SELECT count(?s) {
            ?s a <http://scta.info/resource/quotation> .
          }
          "
  quotesquery = "#{prefixes}

          SELECT count(distinct ?quotes) {
            ?s sctap:quotes ?quotes .
          }
          "
  itemquery = "#{prefixes}

          SELECT count(distinct ?item) {
            ?item <http://scta.info/property/structureType> <http://scta.info/resource/structureItem> .
          }
          "
  commentaryquery = "#{prefixes}

          SELECT count(distinct ?com) {
            ?com <http://scta.info/property/expressionType> <http://scta.info/resource/commentary> .
          }
          "
  namequery = "#{prefixes}

          SELECT count(distinct ?name) {
            ?name a <http://scta.info/resource/person> .
          }
          "
  workquery = "#{prefixes}

          SELECT count(distinct ?work) {
            ?work a <http://scta.info/resource/work> .
          }
          "
  totalquery = "SELECT (count(*) as ?count) WHERE {
                       ?s ?p ?o .
                     }"        
  rdf_query = Lbp::Query.new()
  @quotationcount = rdf_query.query(quotationquery).first[:".1"]
  @quotescount = rdf_query.query(quotesquery).first[:".1"]
  @itemcount = rdf_query.query(itemquery).first[:".1"]
  @commentarycount = rdf_query.query(commentaryquery).first[:".1"]
  @namecount = rdf_query.query(namequery).first[:".1"]
  @workcount = rdf_query.query(workquery).first[:".1"]
  @totalcount = rdf_query.query(totalquery).first[:count].to_i
  


  erb :index
end

get '/logo.png' do
  send_file "public/sctalogo.png"
end
=begin
get '/practice' do

  graph = RDF::Graph.load("public/pp-projectdata.rdf")
  query = RDF::Query.new({
                   :subject => {
                       RDF.type  => RDF::URI("http://scta.info/resource/item"),
                       DC11.title => :title,
                      }
                    })

  query.execute(graph).each do |solution|
    
    puts "title=#{solution.title}"
  end
  end

  get '/construct' do

    query = "#{prefixes}

    CONSTRUCT {
      <http://scta.info/text/plaoulcommentary/commentary> sctap:quotes ?quote .
      }

    WHERE  {
      <http://scta.info/text/plaoulcommentary/commentary> dcterms:hasPart ?p .
      ?p sctap:quotes ?quote .

      }"

    @result = rdf_query(query)
    @result_hash = []
    @predicate = "sctap:quotes"
    @result.each_statement do |statement|
        @result_hash << statement.object

    end
  erb :practice
  #binding.pry



end

get '/main' do
  puts "text"
  erb :main
end
=begin
get '/scta' do
  query = "#{prefixes}

          SELECT ?s ?o
          {
          ?s a <http://scta.info/resource/commentarius> .
          ?s <http://purl.org/dc/elements/1.1/title> ?o  .
          }
          ORDER BY ?s
          "
  @category = 'commentary'
  @result = rdf_query(query)


  erb :subj_display
end
=end

get '/api' do 
  erb :api
end

get '/search' do
  erb :search
end

get '/searchresults' do


  @post = "#{params[:search]}"
  @category = "#{params[:category]}"
  
    if @category == "questionTitle"
      #type = "item"
      predicate = "<http://scta.info/property/questionTitle>"
      query = "#{prefixes}

          SELECT ?s ?o
          {
          ?s #{predicate} ?o  .
          FILTER (REGEX(STR(?o), '#{@post}', 'i')) .
          }
          ORDER BY ?s
          "
    else
      type = @category
      predicate = "<http://purl.org/dc/elements/1.1/title>"
      query = "#{prefixes}

          SELECT ?s ?o
          {

          ?s a <http://scta.info/resource/#{type}> .
          ?s #{predicate} ?o  .
          FILTER (REGEX(STR(?o), '#{@post}', 'i')) .
          }
          ORDER BY ?s
          "
    end
    
  #query_display_simple(query)
  @result = rdf_query(query)
  erb :searchresults
end

post '/sparqlquery' do

  query = "#{params[:query]}"
  query_display_simple(query)
end

get '/iiif/collection/scta' do
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json 
  send_file "public/scta-collection.json"
end
get '/iiif/:commentaryid/collection' do
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json 

  # TODO; not the ideal way to do this
  # Data base should have manifest url for all manifestations
  # collection can then be built from manifesetations
  file = File.read("public/scta-collection.json")
  json = JSON.parse(file)
  newcollection = json["collections"].find {|collection| collection["@id"]=="http://scta.info/iiif/collection/#{params[:commentaryid]}"}
  JSON.pretty_generate(newcollection)
  
end

get '/iiif/:msname/manifest' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  
  

  slug = msname.split("-").last
  commentary_slug = msname.split("-").first
 ## TODO this should be replaced by the create range function used in the 
 ## range supplement creation
  query = "#{prefixes}

          SELECT ?commentary ?item ?order ?title ?witness ?canvas
          {
          ?commentary <http://scta.info/property/slug> '#{commentary_slug}' .
          ?commentary <http://scta.info/property/hasStructureItem> ?item .
          ?item <http://scta.info/property/hasManifestation> ?witness .
          ?item <http://scta.info/property/totalOrderNumber> ?order .
          ?item <http://purl.org/dc/elements/1.1/title> ?title .
          ?witness <http://scta.info/property/hasSlug> '#{slug}' .
          ?witness <http://scta.info/property/isOnCanvas> ?canvas
          }
          ORDER BY ?order
          "

        #@results = rdf_query(query)
        query_obj = Lbp::Query.new()
        @results = query_obj.query(query)


  if @results.count > 0
=begin
      all_structures = []     
      
      first_structure_canvases = []

      @results.each do |result|
        first_structure_canvases << result[:canvas].to_s
      end

      first_structure = {"@id" => "http://scta.info/iiif/#{msname}/range/r1",
                      "@type" => "sc:Range",
                      "label" => "Commentary",
                      #{}"viewingHint" => "top",
                      "canvases" => first_structure_canvases.uniq
                      } 
      all_structures << first_structure               

      items = []
      
      @results.each do |result|
        items << [result[:item], result[:title]]
      end                
      
      result_sets = []
      items.uniq!
      items.each do |item, title|

        filtered_results = @results.dup.filter(:item => item.to_s)
        result_sets << [filtered_results, title]
      end
      i = 1
      result_sets.each do |set, title|
        
        structure_canvases = []
        
        set.each do |item_set|
          structure_canvases << item_set[:canvas].to_s
        end
        
        structure = {"@id" => "http://scta.info/iiif/#{msname}/range/r1-#{i}",
                      "within" => "http://scta.info/iiif/#{msname}/range/r1",
                      "@type" => "sc:Range",
                      "label" => "#{title.to_s}",
                      #{}"viewingHint" => "top",
                      "canvases" => structure_canvases
                      } 

        all_structures << structure
        
        i = i + 1

      end
=end
      
      all_structures = create_range2(msname)

      structure_object = {"structures" => all_structures}
      #all_structures.to_json
      #structure_object.to_json

      json = File.read("public/#{msname}.json")
      secondJsonArray = JSON.parse(json)
      
      newhash = secondJsonArray.merge(structure_object)
      
      JSON.pretty_generate(newhash)
    
    else
      send_file "public/#{msname}.json"
    end

      
end

get '/iiif/:msname/rangelist' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "rangelist"
  create_supplement(msname, type)
  #send_file "public/#{slug}.json"
end
## this route should replace the above
get '/iiif/:msname/supplement/ranges/toc' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "rangelist"
  create_supplement(msname, type)
  #send_file "public/#{slug}.json"
end

get '/iiif/:msname/searchwithin' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "searchwithin"
  create_supplement(msname, type)
end
## this route should replace the above
get '/iiif/:msname/supplement/service/searchwithin' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "searchwithin"
  create_supplement(msname, type)
end

get '/iiif/:msname/supplement/layer/transcription' do |msname|
headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "layerTranscription"
  create_supplement(msname, type)
end

#hard coding this for testing
get '/iiif/:msname/supplement/layer/translation' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "layerTranslation"
  #create_supplement(msname, type)
  send_file "public/supplement-translation-#{msname}-layer.json"
end

#hard coding this for testing
get '/iiif/:msname/supplement/layer/comments' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "layerComments"
  #create_supplement(msname, type)
  send_file "public/supplement-comments-#{msname}-layer.json"
end

#hard coding this for testing
get '/iiif/:msname/layer/translation' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "layerTranslation"
  #create_supplement(msname, type)
  send_file "public/translation-#{msname}-layer.json"
end

#hard coding this for testing
get '/iiif/:msname/layer/comments' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  type = "layerComments"
  #create_supplement(msname, type)
  send_file "public/comments-#{msname}-layer.json"
end

get '/iiif/:msname/layer/transcription' do |msname|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json
  create_transcriptionlayer(msname)
end

# hard coding these now for test
get '/iiif/:slug/list/translation/:folioid' do |slug, folioid|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json 
  send_file "public/translation-#{slug}-#{folioid}.json"
end
get '/iiif/:slug/list/comments/:folioid' do |slug, folioid|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json 
  send_file "public/comments-#{slug}-#{folioid}.json"
end
# end of hard coding for testing

get '/iiif/:slug/list/:folioid' do |slug, folioid|
  headers( "Access-Control-Allow-Origin" => "*")
  content_type :json

  foliordfid = "<http://scta.info/resource/material/#{slug}/#{folioid}>"

  query = "SELECT ?x ?y ?w ?h ?position ?paragraph ?plaintext ?canvasid ?pnumber
          {
          ?zone <http://scta.info/property/hasFolioSide> #{foliordfid} .
          ?zone <http://scta.info/property/isZoneOn> ?canvasid .
          ?zone <http://scta.info/property/ulx> ?x .
          ?zone <http://scta.info/property/uly> ?y .
          ?zone <http://scta.info/property/width> ?w .
          ?zone <http://scta.info/property/height> ?h .
          ?zone <http://scta.info/property/position> ?position .
          ?zone <http://scta.info/property/isZoneOf> ?paragraph .
          ?paragraph <http://scta.info/property/isTranscriptionOf> ?paragraphManifestation .
          ?paragraphManifestation <http://scta.info/property/isManifestationOf> ?paragraphExpression .
          ?paragraphExpression <http://scta.info/property/paragraphNumber> ?pnumber .
          ?paragraph <http://scta.info/property/plaintext> ?plaintext .
          }
          ORDER BY ?pnumber ?position
          "

        #@results = rdf_query(query)
        query_obj = Lbp::Query.new()
        @results = query_obj.query(query)

        


    annotationarray = []
      
      @results.each do |result|
        
        pid = result['paragraph'].to_s.split("/").last
        paragraph = result['paragraph'].to_s
        paragraphtext = HTTParty.get(result['plaintext'].to_s)
        entryhash = {"@type" => "oa:Annotation",
        "@id" => "http://scta.info/iiif/#{slug}/annotation/#{pid}",
        "motivation" => "sc:painting",
        "resource" => {
            "@id" => "#{result[:plaintext]}",
            "@type" => "dctypes:Text",
            #"@type" => "cnt:ContentAsText",
            "chars" => "#{paragraphtext}</br> Metadata avaialble for this paragraph here: <a href='#{paragraph}'>#{paragraph}</a>.",
            "format" => "text/html"
        },
        "on" => "#{result[:canvasid]}#xywh=#{result[:x]},#{result[:y]},#{result[:w]},#{result[:h]}"
      }
        annotationarray << entryhash
       end

       annotationlistcontent = {"@context" => "http://iiif.io/api/presentation/2/context.json", 
        "@id" => "http://scta.info/iiif/#{slug}/list/#{folioid}",
        "@type" => "sc:AnnotationList",
        "within" => {
          "@id" => "http://scta.info/iiif/pp-sorb/layer/transcription",
          "@type" => "sc:Layer",
          "label" => "Diplomatic Transcription"
        },
        "resources" => annotationarray
       }
    JSON.pretty_generate(annotationlistcontent)
end


get '/textsearch/:string' do |string| 

@searchstring = string
response = HTTParty.get("http://localhost:8983/solr/collection1/select?q=#{string}&rows=100&wt=json&indent=true") 
json = JSON.parse(response.body)
response_hash = json.to_hash
@docs_array = response_hash["response"]["docs"]

erb :textsearch
end

get '/list/:type' do |type|

  @subjectid = "<http://scta.info/list/#{type}>"
  query = "#{prefixes}

          SELECT ?s ?o
          {
          ?s a <http://scta.info/resource/#{type}> .
          ?s <http://purl.org/dc/elements/1.1/title> ?o  .
          }
          ORDER BY ?s
          "
  
  @result = rdf_query(query)
  
  accept_type = request.env['HTTP_ACCEPT']

  if accept_type.include? "text/html"
    erb :subj_display
    
  else
    RDF::Graph.new do |graph|
      @result.each do |solution|
        s = RDF::URI(@subjectid)
        p = RDF::URI("http://scta.info/property/hasListMember")
        o = solution[:s]
        graph << [s, p, o]

      end
    end
  end
end

get '/?:p1?/?:p2?/?:p3?/?:p4?/?:p5?/?:p6?/?:p7?' do ||

  if params[:p7] != nil
    @subjectid = "<http://scta.info/#{params[:p1]}/#{params[:p2]}/#{params[:p3]}/#{params[:p4]}/#{params[:p5]}/#{params[:p6]}/#{params[:p7]}>"
  elsif params[:p6] != nil
    @subjectid = "<http://scta.info/#{params[:p1]}/#{params[:p2]}/#{params[:p3]}/#{params[:p4]}/#{params[:p5]}/#{params[:p6]}>"
  elsif params[:p5] != nil
    @subjectid = "<http://scta.info/#{params[:p1]}/#{params[:p2]}/#{params[:p3]}/#{params[:p4]}/#{params[:p5]}>"
  elsif params[:p4] != nil
    @subjectid = "<http://scta.info/#{params[:p1]}/#{params[:p2]}/#{params[:p3]}/#{params[:p4]}>"
  elsif params[:p3] != nil
    @subjectid = "<http://scta.info/#{params[:p1]}/#{params[:p2]}/#{params[:p3]}>"
  elsif params[:p2] != nil
    @subjectid = "<http://scta.info/#{params[:p1]}/#{params[:p2]}>"
  elsif params[:p1] != nil
    @subjectid = "<http://scta.info/#{params[:p1]}>"
  end

  query = "#{prefixes}

          SELECT ?p ?o ?ptype
          {
          #{@subjectid} ?p ?o .
          OPTIONAL {
              ?p rdfs:subPropertyOf ?ptype .
              }

          }
          ORDER BY ?p
          "

  #@result = rdf_query(query)
    #test using Lbp library
    query_obj = Lbp::Query.new()
    @result = query_obj.query(query)
  
  if params[:p1] == 'resource'
    @resourcetype = params[:p2]
  end

  accept_type = request.env['HTTP_ACCEPT']

  if accept_type.include? "text/html"

    @count = @result.count
    @title = @result.first[:o] # this works for now but doesn't seem like a great method since if the title ever ceased to the first triple in the query output this wouldn't work.



    @pubinfo = @result.dup.filter(:ptype => RDF::URI("http://scta.info/property/pubInfo"))
    @contentinfo = @result.dup.filter(:ptype => RDF::URI("http://scta.info/property/contentInfo"))
    @linkinginfo = @result.dup.filter(:ptype => RDF::URI("http://scta.info/property/linkingInfo"))
    @miscinfo = @result.dup.filter(:ptype => nil)


    @sameas = @result.dup.filter(:p => RDF::URI("http://www.w3.org/2002/07/owl#sameAs"))
    
    if @resourcetype == 'person' && @sameas.count > 0
      dbpediaAddress = @sameas[0][:o]
      dbpediaGraph = RDF::Graph.load(dbpediaAddress)
      query = RDF::Query.new({:person =>
                                  {
                                      RDF::URI("http://dbpedia.org/ontology/abstract") => :abstract
                                  #RDF::URI("http://dbpedia.org/ontology/birthDate") => :birthDate
                                  }
                             })
      result  = query.execute(dbpediaGraph)
      @english_result = result.find { |solution| solution.abstract.language == :en}
    end
  
  erb :obj_pred_display

  else
    RDF::Graph.new do |graph|
      @result.each do |solution|
        s = RDF::URI(@subjectid)
        p = solution[:p]
        o = solution[:o]
        graph << [s, p, o]

      end
    end
  end
end
















