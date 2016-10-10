def create_range3(msname, expressionid)
  #slug = msname.split("-").last
  #commentary_slug = msname.split("-").first


# TODO need to different range creating functions -- one for a manifest for a codex and one for a manifest for
# an expression in that codex.
# if a manifest for the codex is requested, ranges should be created for all expressions within the codex
# as follows: change query to look for any expression with a manifestation that is in part of the specified codex
# then create range for each expression
# if manifest for an expression is given, then only a range for that expression should be made.
# urls could look like the following: http://scta.info/iiif/codex/bnf135/manifest or http://scta.info/iiif/plaoulcommentary/bnf135/manifest
  query = "
          SELECT ?commentary ?topdivision ?topdivision_title ?item ?order ?title ?witness ?canvas
          {
          ?commentary <http://scta.info/property/hasManifestation> <http://scta.info/resource/#{expressionid}/#{msname}> .
          ?commentary <http://purl.org/dc/terms/hasPart> ?topdivision .
          ?topdivision <http://purl.org/dc/elements/1.1/title> ?topdivision_title .
          ?topdivision <http://scta.info/property/hasStructureItem> ?item .
          ?item <http://scta.info/property/hasManifestation> ?witness .
          ?item <http://scta.info/property/totalOrderNumber> ?order .
          ?item <http://purl.org/dc/elements/1.1/title> ?title .
          ?witness <http://scta.info/property/hasSlug> '#{msname}' .
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
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
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
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
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
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{msname}",
                      "logo": "http://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                      }

        all_structures << structure


    end
  end
  return all_structures
end
