require 'lbp'
require 'json'

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
                      "desription": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "licnese": "Creative Commons"
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
                      "desription": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "licnese": "Creative Commons"
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
    all_structures = create_range(msname)
    final_object = {
        "supplement": {
          "@id": "http://scta.info/iiif/#{commentary_slug}-#{slug}/rangelist",
          "@type": "sc:rangelist",
          "attribution": "Data provided by the Sentences Commentary Text Archive",
          "desription": "A range list for Sentences Commentary #{msname}",
          "logo": "http://scta.info/logo.png",
          "licnese": "Creative Commons",
          "manifests": [manifest],
          "structures": all_structures
          }
        }


  elsif type == "searchwithin"
    service = create_searchwithin(msname)
    final_object = {
      "supplement": {
          "@id": "http://scta.info/iiif/#{commentary_slug}-#{slug}/searchwithin",
          "@type": "sc:searchWithin",
          "attribution": "Data provided by the Sentences Commentary Text Archive",
          "desription": "A search within service for Sentences Commentary #{msname}",
          "logo": "http://scta.info/logo.png",
          "licnese": "Creative Commons",
          "manifests": [manifest],
          "service": service
          }
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