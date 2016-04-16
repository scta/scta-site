require 'lbp'
require 'json'
#require 'pry'

def create_range2(msname)
  slug = msname.split("-").last
  commentary_slug = msname.split("-").first

  query = "
          SELECT ?commentary ?topdivision ?topdivision_title ?item ?order ?title ?witness ?canvas
          {
          ?commentary <http://scta.info/property/slug> '#{commentary_slug}' .
          ?commentary <http://purl.org/dc/terms/hasPart> ?topdivision .
          ?topdivision <http://purl.org/dc/elements/1.1/title> ?topdivision_title .
          ?topdivision <http://scta.info/property/hasItem> ?item .
          ?item <http://scta.info/property/hasWitness> ?witness .
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

  all_structures = []           
  
  if @results.count > 0
      
    # top divisions creates an array for all top level divisions in commentary 
    # usually these divisions are book 1, book 2, book3, book 4
    topdivisions = []
    # the results of the query are parsed creating a new array called top divisions
    # that contains a a list of divisions that include the division id and the division title
    @results.each do |result|
      topdivisions << [result[:topdivision].to_s, result[:topdivision_title]]
    end

    #the resulting array is then reduced to unique values only.
    topdivisions.uniq!

    # an array is made for all the items that will display
    items = []
    
    # the items array is a list of item resources, each entry in the list
    # includes the item id, the item title and the top division to which it belongs  
    @results.each do |result|
      items << [result[:item], result[:title], result[:topdivision], result[:topdivision_title]]
    end                
    
    ## a new array called result sets is built to get 
    # the full set of information for each item (including associated canvases) 
    # associated with topdivision id and top division title
    result_sets = []
    items.uniq!
      
    items.each do |item, title, topdivision, topdivision_title|
      filtered_results = @results.dup.filter(:item => item.to_s)
      result_sets << [filtered_results, title, topdivision.to_s, topdivision_title]
    end
      
    #create ranges array for each topdivision and item ranges associated within each topdivision
    topdivision_ranges = []
    item_ranges = []

    r = 1
    
    topdivisions.each do |topdivisionid, topdivision_title|
      
      topdivision_ranges << "http://scta.info/iiif/#{msname}/range/r1-#{r}"

      next_r = 1
      result_sets.each do |result, title, item_topdivisionid, topdivision_title|
        if item_topdivisionid == topdivisionid
          item_ranges << {topdivision_rangeid: "http://scta.info/iiif/#{msname}/range/r1-#{r}", 
                          item_rangeid: "http://scta.info/iiif/#{msname}/range/r1-#{r}-#{next_r}",
                          set: result,
                          title: title.to_s,
                          topdivision_title: topdivision_title
                          }
          end
          next_r = next_r + 1
        end
        r = r + 1
      end



    first_structure = {"@id" => "http://scta.info/iiif/#{msname}/range/r1",
                      "@type" => "sc:Range",
                      "label" => "Commentary",
                      "viewingHint" => "top",
                      "ranges" => topdivision_ranges,
                      "attribution": "Data provided by the Sentences Commentary Text Archive",
                      "description": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    } 

    #add wrapper structure to total range array
    all_structures << first_structure 

    # begin loop to create topdivision structures  
    r = 1
    
    topdivisions.each do |id, title|
        
        ranges2 = item_ranges.map do |object| 
          
          if object[:topdivision_rangeid] == "http://scta.info/iiif/#{msname}/range/r1-#{r}" 
             object[:item_rangeid]
          end
        end

        division_canvases =[]
        item_ranges.each do |object|
          if object[:topdivision_rangeid] == "http://scta.info/iiif/#{msname}/range/r1-#{r}" 
            object[:set].each do |item_set|
              division_canvases << item_set[:canvas].to_s
            end
          end
        end
        division_canvases.uniq!
        ranges2.compact!
        structure = {"@id" => "http://scta.info/iiif/#{msname}/range/r1-#{r}",
                      "within" => "http://scta.info/iiif/#{msname}/range/r1",
                      "@type" => "sc:Range",
                      "label" => title,
                      "ranges" => ranges2,
                      # mirador has bug if this canvases are also listed 
                      #"canvases" => division_canvases,
                      "attribution": "Data provided by the Sentences Commentary Text Archive",
                      "description": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    } 
        all_structures << structure            
        r = r + 1            
      end
      
      ## begin loop to create all item level structures
      item_ranges.each do |object|
        
        structure_canvases = []
        
        object[:set].each do |item_set|
          structure_canvases << item_set[:canvas].to_s
        end
        
        title = object[:title].to_s.split("#{object[:topdivision_title]}, ").last
        structure = {"@id" => object[:item_rangeid],
                      "within" => object[:topdivision_rangeid],
                      "@type" => "sc:Range",
                      "label" => title,
                      "canvases" => structure_canvases,
                      "attribution": "Data provided by the Sentences Commentary Text Archive",
                      "description": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                      } 

        all_structures << structure
        
        
    end
  end
  return all_structures
end


def create_range(msname)
	slug = msname.split("-").last
  commentary_slug = msname.split("-").first

  query = "
  				SELECT ?commentary ?item ?order ?title ?witness ?canvas
          {
          ?commentary <http://scta.info/property/slug> '#{commentary_slug}' .
          ?commentary <http://scta.info/property/hasItem> ?item .
          ?item <http://scta.info/property/hasWitness> ?witness .
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

  all_structures = []           
  if @results.count > 0
      #first_structure_canvases = []

      #@results.each do |result|
      #  first_structure_canvases << result[:canvas].to_s
     # end

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

      ranges = []

      r = 1
      result_sets.each do 
        ranges << "http://scta.info/iiif/#{msname}/range/r1-#{r}"
        r = r + 1
      end

      first_structure = {"@id" => "http://scta.info/iiif/#{msname}/range/r1",
                      "@type" => "sc:Range",
                      "label" => "Commentary",
                      "viewingHint" => "top",
                      #{}"canvases" => first_structure_canvases.uniq
                      "ranges" => ranges,
                      "attribution": "Data provided by the Sentences Commentary Text Archive",
                      "description": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    } 
      
      all_structures << first_structure               
      
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
                      "canvases" => structure_canvases,
                      "attribution": "Data provided by the Sentences Commentary Text Archive",
                      "description": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                      } 

        all_structures << structure
        
        i = i + 1
    end
  end
  return all_structures
end

def create_supplement (msname, type)
  slug = msname.split("-").last
  commentary_slug = msname.split("-").first

  query = "
          SELECT ?manifestOfficial
          {
          ?commentary <http://scta.info/property/slug> '#{commentary_slug}' .
          ?commentary <http://scta.info/property/hasWitness> ?commentary_witness .
          ?commentary_witness <http://scta.info/property/hasSlug> '#{slug}' .
          ?commentary_witness <http://scta.info/property/manifestOfficial> ?manifestOfficial .
          }
          "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)
  if results[0] != nil
    manifest = results[0][:manifestOfficial].to_s
  else
    manifest = "http://scta.info/iiif/#{msname}/manifest"
  end
 
  if type == "rangelist"
    all_ranges = create_range2(msname)
    final_object = 
        {
          "@id": "http://scta.info/iiif/#{commentary_slug}-#{slug}/rangelist",
          "@type": "sc:supplement",
          "profile": "http://iiif.io/api/0.1/supplement/ranges",
          "within": [manifest],
          "viewingHint": "http://iiif.io/api/services/webmention/discard",

          "attribution": "Data provided by the Sentences Commentary Text Archive",
          "description": "A range list for Sentences Commentary #{msname}",
          "logo": "http://scta.info/logo.png",
          "license": "https://creativecommons.org/publicdomain/zero/1.0/",
          # should structures be changed to "ranges"
          "ranges": all_ranges
        }


  elsif type == "searchwithin"
    service = create_searchwithin(msname)
    final_object = {
          "@id": "http://scta.info/iiif/#{commentary_slug}-#{slug}/searchwithin",
          "@type": "sc:supplement",
          "profile": "http://iiif.io/api/0.1/supplement/service",
          "within": [manifest],
          "viewingHint": "http://iiif.io/api/services/webmention/discard",

          "attribution": "Data provided by the Sentences Commentary Text Archive",
          "description": "A search within service for Sentences Commentary #{msname}",
          "logo": "http://scta.info/logo.png",
          "license": "https://creativecommons.org/publicdomain/zero/1.0/",
          "service": service
        }

  elsif type == "layerTranscription"
    transcription_layer = "http://scta.info/iiif/#{msname}/layer/transcription"
    final_object = {
          "@id": "http://scta.info/iiif/#{commentary_slug}-#{slug}/supplement/layer/transcription",
          "@type": "sc:supplement",
          "profile": "http://iiif.io/api/0.1/supplement/layer",
          "within": [manifest],
          "viewingHint": "http://iiif.io/api/services/webmention/discard",
          
          "attribution": "Data provided by the Sentences Commentary Text Archive",
          "description": "Layers published by the Sentences Commentary #{msname}",
          "logo": "http://scta.info/logo.png",
          "license": "https://creativecommons.org/publicdomain/zero/1.0/",
          "layer": transcription_layer
          }     
  end     

      JSON.pretty_generate(final_object)

end

def create_searchwithin (msname)
  slug = msname.split("-").last
  commentary_slug = msname.split("-").first
  service = {
          "@context": "http://iiif.io/api/search/0/context.json",
          "@id": "http://exist.scta.info/exist/apps/scta/iiif/#{commentary_slug}-#{slug}/search",
          "profile": "http://iiif.io/api/search/0/search",
          "label": "Search within this manifest"
          }
  return service
end

def create_transcriptionlayer (msname)
  slug = msname.split("-").last
  commentary_slug = msname.split("-").first
  lists = []


  query = "
          SELECT ?commentary ?item ?order ?title ?witness ?folio ?annolist ?canvasid
          {
          ?commentary <http://scta.info/property/slug> '#{commentary_slug}' .
          ?commentary <http://scta.info/property/hasItem> ?item .
          ?item <http://scta.info/property/hasWitness> ?witness .
          ?item <http://scta.info/property/totalOrderNumber> ?order .
          ?item <http://purl.org/dc/elements/1.1/title> ?title .
          ?witness <http://scta.info/property/hasSlug> '#{slug}' .
          ?witness <http://scta.info/property/hasFolioSide> ?folio . 
          ?folio <http://scta.info/property/isOnCanvas> ?canvasid .
          ?folio <http://scta.info/property/hasAnnotationList> ?annolist . 

          }
          ORDER BY ?order
          "

        #@results = rdf_query(query)
        query_obj = Lbp::Query.new()
        results = query_obj.query(query)
  
  lists = results.map {|result| {"@id": result[:annolist].to_s, "sc:forCanvas": result[:canvasid].to_s} }
  lists.uniq!
  
  layer = {"@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "http://scta.info/iiif/layer/transcription",
    "@type": "sc:Layer",
    "label": "Diplomatic Transcription",
    "attribution": "Data provided by the Sentences Commentary Text Archive",
    "description": "Transcription layer published by the Sentences Commentary #{msname}",
    "logo": "http://scta.info/logo.png",
    "license": "https://creativecommons.org/publicdomain/zero/1.0/",
    "otherContent": lists

  }
  return JSON.pretty_generate(layer)
end