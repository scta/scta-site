def create_range(manifestationid)

  msname = manifestationid.split("/").last
  query = "
  SELECT ?wrapper_title ?topdivision ?topdivision_title ?item ?item_expression ?order ?title ?witness ?canvas
  {
    <http://scta.info/resource/#{manifestationid}> <http://scta.info/property/isManifestationOf> ?wrapper_expression.
    ?wrapper_expression <http://purl.org/dc/elements/1.1/title> ?wrapper_title .
    <http://scta.info/resource/#{manifestationid}> <http://purl.org/dc/terms/hasPart> ?topdivision .
    ?topdivision <http://scta.info/property/isManifestationOf> ?topdivision_expression .
    ?topdivision_expression <http://purl.org/dc/elements/1.1/title> ?topdivision_title .
    ?topdivision <http://scta.info/property/hasStructureItem> ?item .
    ?item <http://scta.info/property/isManifestationOf> ?item_expression .
    ?item_expression <http://scta.info/property/totalOrderNumber> ?order .
    ?item_expression <http://purl.org/dc/elements/1.1/title> ?title .
    ?item <http://scta.info/property/isOnSurface> ?surface .
    ?surface <http://scta.info/property/hasISurface> ?isurface .
    ?isurface <http://scta.info/property/hasCanvas> ?canvas
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

      topdivision_ranges << "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}"

      next_r = 1
      result_sets.each do |result, title, item_topdivisionid, topdivision_title|
        if item_topdivisionid == topdivisionid
          item_ranges << {topdivision_rangeid: "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}",
                          item_rangeid: "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}-#{next_r}",
                          set: result,
                          title: title.to_s,
                          topdivision_title: topdivision_title
                          }
          end
          next_r = next_r + 1
        end
        r = r + 1
      end



    first_structure = {"@id" => "https://scta.info/iiif/#{manifestationid}/range/r1",
                      "@type" => "sc:Range",
                      "label" => @results[0][:wrapper_title].to_s,
                      "viewingHint" => "top",
                      "ranges" => topdivision_ranges,
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{manifestationid}",
                      "logo": "https://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    }

    #add wrapper structure to total range array
    all_structures << first_structure

    # begin loop to create topdivision structures
    r = 1

    topdivisions.each do |id, title|

        ranges2 = item_ranges.map do |object|

          if object[:topdivision_rangeid] == "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}"
             object[:item_rangeid]
          end
        end

        division_canvases =[]
        item_ranges.each do |object|
          if object[:topdivision_rangeid] == "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}"
            object[:set].each do |item_set|
              division_canvases << item_set[:canvas].to_s
            end
          end
        end
        division_canvases.uniq!
        ranges2.compact!
        structure = {"@id" => "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}",
                      "within" => "https://scta.info/iiif/#{manifestationid}/range/r1",
                      "@type" => "sc:Range",
                      "label" => title,
                      "ranges" => ranges2,
                      # mirador has bug if this canvases are also listed
                      #"canvases" => division_canvases,
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{manifestationid}",
                      "logo": "https://scta.info/logo.png",
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
                      "logo": "https://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                      }

        all_structures << structure


    end
  else
    # create_range2 generator is targeted at top level expression without any further collection divisions
    # TODO there is a lot of repetition; range creation needs massive refactoring
    all_structures = create_range2(manifestationid)
  end

  return all_structures
end
## create_range2 is the better function, but the ranges created are often to complex and heavy for web and mirador
def create_range2(manifestationid)
  query = "
  SELECT ?expression ?expression_title ?level ?part ?part_title ?part_order ?part_level ?canvas ?part_child ?part_child_order ?part_parent ?part_order
  {
    <http://scta.info/resource/#{manifestationid}> <http://scta.info/property/isManifestationOf> ?expression .
    ?expression <http://purl.org/dc/elements/1.1/title> ?expression_title .
  	?expression <http://scta.info/property/level> ?level .
  	?part <http://scta.info/property/isPartOfTopLevelExpression> ?expression .
    ?part <http://scta.info/property/totalOrderNumber> ?part_order .
    ?part <http://scta.info/property/structureType> ?structureType .
    ?part <http://purl.org/dc/elements/1.1/title> ?part_title .
    FILTER (?structureType = <http://scta.info/resource/structureCollection> || ?structureType =  <http://scta.info/resource/structureItem>)
      ?part <http://scta.info/property/level> ?part_level .
    OPTIONAL{
	     ?part <http://purl.org/dc/terms/isPartOf> ?part_parent .
	    }
    OPTIONAL{
      ?part <http://purl.org/dc/terms/hasPart> ?part_child .
      ?part_child <http://scta.info/property/totalOrderNumber> ?part_child_order .
    }
    OPTIONAL{
      ?part <http://scta.info/property/hasManifestation> ?part_manifestation .
      ?part_manifestation <http://scta.info/property/isPartOfTopLevelManifestation> <http://scta.info/resource/#{manifestationid}> .
      ?part_manifestation <http://scta.info/property/isOnSurface> ?surface .
      ?surface <http://scta.info/property/hasISurface> ?isurface .
      ?isurface <http://scta.info/property/hasCanvas> ?canvas
    }
  }
 ORDER BY ?part_order ?part_child_order"

  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  @results = query_obj.query(query)
  if @results.count > 0

    levels = @results.map do |result|
      result[:part_level].to_s
    end
    levels.uniq!
    structures = []

    parts = @results.map do |result|
      result[:part].to_s

    end
    parts.uniq!

    groups = []
    parts.each do |part|
      part_children = []
      canvases = []
      part_parent = ""
      part_level = ""
      part_title = ""
      part_order = ""
      @results.each do |result|
        if result[:part].to_s == part
          part_children << {part_child: result[:part_child].to_s, part_child_order: result[:part_child_order]}
          canvases << result[:canvas].to_s
          part_parent = result[:part_parent].to_s
          part_level = result[:part_level].to_s
          part_title = result[:part_title].to_s
          part_order = result[:part_order].to_s
        end
      end

      group = {partid: part,
              children: part_children,
              canvases: canvases.uniq,
              parent: part_parent,
              level: part_level,
              part_title: part_title,
              part_order: part_order
            }
    groups << group

    end

    structures = []

    groups.each do |group|

        if group[:children][0][:part_child] != ""
          rangeid = group[:partid].split('/').last
          parent_rangeid = group[:parent].split('/').last
          group[:children].sort! { |a,b| a[:part_child_order] <=> b[:part_child_order]}
          children_ranges = group[:children].map do |child|
            child_short_id = child[:part_child].to_s.split('/').last
            "https://scta.info/iiif/#{manifestationid}/range/#{child_short_id}"
          end


          structure = {"@id" => "https://scta.info/iiif/#{manifestationid}/range/#{rangeid}",
                      "within" => "https://scta.info/iiif/#{manifestationid}/range/#{parent_rangeid}",
                      "@type" => "sc:Range",
                      "label" => group[:part_title],
                      "ranges" => children_ranges,
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{manifestationid}",
                      "logo": "https://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    }
                    structures << structure
        else
          rangeid = group[:partid].split('/').last
          parent_rangeid = group[:parent].split('/').last
          structure = {"@id" => "https://scta.info/iiif/#{manifestationid}/range/#{rangeid}",
                      "within" => "https://scta.info/iiif/#{manifestationid}/range/#{parent_rangeid}",
                      "@type" => "sc:Range",
                      "label" => group[:part_title],
                      "canvases" => group[:canvases],
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{manifestationid}",
                      "logo": "https://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    }
                    structures << structure

        end
    end
  topdivision_ranges = []
     groups.map do |group|
      if group[:level] == "2"
        topdivision_ranges << "https://scta.info/iiif/#{manifestationid}/range/#{group[:partid].to_s.split('/').last}"
      end
    end
    top_structure =
     {"@id" => "https://scta.info/iiif/#{manifestationid}/range/#{@results[0][:expression].to_s.split('/').last}",
                      "@type" => "sc:Range",
                      "label" => @results[0][:expression_title],
                      "viewingHint" => "top",
                      "ranges" => topdivision_ranges,
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{manifestationid}",
                      "logo": "https://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    }
    structures << top_structure
    #JSON.pretty_generate(structures)
  else
    # create_range3 generator is targeted at non top level expressions
    # TODO there is a lot of repetition; range creation needs massive refactoring
    # this is a TERRIBLE way to do this. it takes 3 queries to get to create_range3
    # thiis a temporary hack fix
    create_range3(manifestationid)
  end
end

# This range generator is targeted for ranges below the top level expression level
# TODO there is a lot of repetition; range creation needs massive refactoring
def create_range3(manifestationid)

  msname = manifestationid.split("/").last
  query = "
  SELECT ?wrapper_title ?topdivision ?topdivision_title ?item ?item_expression ?order ?title ?witness ?canvas
  {
    <http://scta.info/resource/#{manifestationid}> <http://scta.info/property/isPartOfTopLevelManifestation> ?topLevelManifestation .
    ?topLevelManifestation <http://purl.org/dc/terms/hasPart> ?topdivision .
    ?topdivision <http://scta.info/property/shortId> '#{manifestationid}' .
    ?topdivision <http://scta.info/property/isManifestationOf> ?wrapper_expression .
    ?wrapper_expression <http://purl.org/dc/elements/1.1/title> ?wrapper_title .
    ?topdivision <http://scta.info/property/isManifestationOf> ?topdivision_expression .
    ?topdivision_expression <http://purl.org/dc/elements/1.1/title> ?topdivision_title .
    ?topdivision <http://scta.info/property/hasStructureItem> ?item .
    ?item <http://scta.info/property/isManifestationOf> ?item_expression .
    ?item_expression <http://scta.info/property/totalOrderNumber> ?order .
    ?item_expression <http://purl.org/dc/elements/1.1/title> ?title .
    ?item <http://scta.info/property/isOnSurface> ?surface .
    ?surface <http://scta.info/property/hasISurface> ?isurface .
    ?isurface <http://scta.info/property/hasCanvas> ?canvas
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

      topdivision_ranges << "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}"

      next_r = 1
      result_sets.each do |result, title, item_topdivisionid, topdivision_title|
        if item_topdivisionid == topdivisionid
          item_ranges << {topdivision_rangeid: "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}",
                          item_rangeid: "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}-#{next_r}",
                          set: result,
                          title: title.to_s,
                          topdivision_title: topdivision_title
                          }
          end
          next_r = next_r + 1
        end
        r = r + 1
      end



    first_structure = {"@id" => "https://scta.info/iiif/#{manifestationid}/range/r1",
                      "@type" => "sc:Range",
                      "label" => @results[0][:wrapper_title].to_s,
                      "viewingHint" => "top",
                      "ranges" => topdivision_ranges,
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{manifestationid}",
                      "logo": "https://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                    }

    #add wrapper structure to total range array
    all_structures << first_structure

    # begin loop to create topdivision structures
    r = 1

    topdivisions.each do |id, title|

        ranges2 = item_ranges.map do |object|

          if object[:topdivision_rangeid] == "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}"
             object[:item_rangeid]
          end
        end

        division_canvases =[]
        item_ranges.each do |object|
          if object[:topdivision_rangeid] == "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}"
            object[:set].each do |item_set|
              division_canvases << item_set[:canvas].to_s
            end
          end
        end
        division_canvases.uniq!
        ranges2.compact!
        structure = {"@id" => "https://scta.info/iiif/#{manifestationid}/range/r1-#{r}",
                      "within" => "https://scta.info/iiif/#{manifestationid}/range/r1",
                      "@type" => "sc:Range",
                      "label" => title,
                      "ranges" => ranges2,
                      # mirador has bug if this canvases are also listed
                      #"canvases" => division_canvases,
                      "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
                      "description": "A range for Sentences Commentary #{manifestationid}",
                      "logo": "https://scta.info/logo.png",
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
                      "logo": "https://scta.info/logo.png",
                      "license": "https://creativecommons.org/publicdomain/zero/1.0/"
                      }

        all_structures << structure


    end
  else
    all_structures = []
  end

  return all_structures
end
