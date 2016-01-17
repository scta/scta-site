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


  if @results.count > 0
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
      
      
      final_object = {
		  "supplement": {
				"@id": "http://scta.info/iiif/#{commentary_slug}-#{slug}/rangelist",
				"@type": "sc:rangelist",
				"manifests": ["http://www.e-codices.unifr.ch/metadata/iiif/kba-WettF0015/manifest.json"],
				"structures": all_structures
				}
			}

      JSON.pretty_generate(final_object)
	end
end