
def get_official_manifest(shortid)
  query = "
  SELECT ?manifest
  {
    <http://scta.info/resource/#{shortid}> <http://scta.info/property/hasCodexItem> ?icodex .
    ?icodex <http://scta.info/property/hasOfficialManifest> ?manifest .
  }
  "

  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)
  manifest = open(get_official_manifest_url(shortid)).read
  return manifest

end

def get_official_manifest_url(shortid)
  query = "
  SELECT ?manifest
  {
    <http://scta.info/resource/#{shortid}> <http://scta.info/property/hasCodexItem> ?icodex .
    ?icodex <http://scta.info/property/hasOfficialManifest> ?manifest .
  }
  "

  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)
  if results.count > 0
    manifest = results[0][:manifest].to_s
  else
    manifest = ""
  end
  return manifest

end

def create_manifest(shortid)
  query = "
  SELECT ?surface ?surface_title ?isurface ?canvas ?canvas_label ?canvas_width ?canvas_height ?image_height ?image_width ?image_type ?image_format ?image_service ?image_service_profile ?anno ?resource
  {
    <http://scta.info/resource/#{shortid}> <http://scta.info/property/hasSurface> ?surface .
    ?surface <http://purl.org/dc/elements/1.1/title> ?surface_title .
    ?surface <http://scta.info/property/hasISurface> ?isurface .
    ?surface <http://scta.info/property/order> ?order .
    ?isurface <http://scta.info/property/hasCanvas> ?canvas .
    ?canvas <http://www.w3.org/2003/12/exif/ns#width> ?canvas_width .
    ?canvas <http://www.w3.org/2003/12/exif/ns#height> ?canvas_height .
    OPTIONAL{
    ?canvas <http://iiif.io/api/presentation/2#hasImageAnnotations> ?bn .
    }
    OPTIONAL{
    ?canvas <http://www.shared-canvas.org/ns/hasImageAnnotations> ?bn .
    }
    ?bn <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?anno .
    ?anno <http://www.w3.org/ns/oa#hasBody> ?resource .
    ?resource <http://www.w3.org/2003/12/exif/ns#height> ?image_height .
    ?resource <http://www.w3.org/2003/12/exif/ns#width> ?image_width .
    ?resource <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?image_type .
    ?resource <http://purl.org/dc/elements/1.1/format> ?image_format .
    OPTIONAL{
      ?resource <http://rdfs.org/sioc/services#has_service> ?image_service .
    }
    OPTIONAL{
      ?resource <http://www.shared-canvas.org/ns/hasRelatedService> ?image_service .
    }
    OPTIONAL{
      ?image_service <http://usefulinc.com/ns/doap#implements> ?image_service_profile .
    }
    OPTIONAL{
      ?image_service <http://purl.org/dc/terms/conformsTo> ?image_service_profile .
    }
  }
  ORDER BY ?order
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  if results.length == 0
    get_official_manifest(shortid)
  else

  canvases = []
  previous_canvas = ""
  number = 1
  results.each do |result|
    #this conditional is meant to deal with face-pages canvas, in other words cases where two surfaces have the save canvas
    unless result[:canvas].to_s == previous_canvas
      image_profile = result[:image_service_profile].nil? ? "http://iiif.io/api/image/1/level2.json" : result[:image_service_profile]
      #temporary solution to deal with older context for gallica images
      # not a long term solution
      context = if result[:canvas].to_s.include? "gallica.bnf.fr"
            "http://iiif.io/api/image/1/context.json"
          elsif result[:canvas].to_s.include? "iiif.lib.harvard.edu"
            "http://iiif.io/api/image/1/context.json"
          else
            "http://iiif.io/api/image/2/context.json"
        end
      ### end temporary measure.

      canvas = {
        "@id": result[:canvas],
        "@type": "sc:Canvas",
        "label": result[:surface_title],
        "height": result[:canvas_height],
        "width": result[:canvas_width],
        "images": [
          {"@id": result[:anno],
            "@type": "oa:Annotation",
            "motivation": "sc:painting",
            "on": result[:canvas],
            "resource": {
              "@id": result[:resource],
              "@type": result[:image_type],
              "format": result[:image_format],
              "height": result[:image_height],
              "width": result[:image_height],
              "service": {
                "@context": context,
                "@id": result[:image_service],
                "profile": image_profile
              }
            }
          }
        ],
        "otherContent": [
          {
            "@id": "http://scta.info/exist/apps/scta-app/folio-annotation-list.xq?surface_id=#{result[:surface].to_s}",
            "@type": "sc:AnnotationList"
          }
        ]
      }


      canvases << canvas
    end
    previous_canvas = result[:canvas]
    number = number + 1
  end

  manifest = {
    "@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "http://scta.info/iiif/codex/#{shortid}/manifest",
    "@type": "sc:Manifest",
    "label": "#{shortid}",
    "description": "Manifest Description",
    "license": "https://creativecommons.org/publicdomain/zero/1.0/",
    "service": {
      "@context": "http://iiif.io/api/search/1/context.json",
      "@id": "http://exist.scta.info/exist/apps/scta-app/iiif/#{shortid}/search",
      "profile": "http://iiif.io/api/search/1/search",
      "label": "Search within this manifest"
    },
    "sequences": [
      {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "http://scta.info/iiif/codex/#{shortid}/sequence/normal",
        "@type": "sc:Sequence",
        "label": "Current page order",
        "viewingDirection": "left-to-right",
        "viewingHint": "paged",
        "canvases": canvases
      }
    ]
  }

  JSON.pretty_generate(manifest)
  end

end
def create_expression_manifest(manifestationid)
  # query = "
  # SELECT ?surface ?surface_title ?isurface ?canvas ?canvas_label ?canvas_width ?canvas_height ?image_height ?image_width ?image_type ?image_format ?image_service ?image_service_profile ?anno ?resource
  # {
  #   <http://scta.info/resource/#{manifestationid}> <http://scta.info/property/hasStructureItem> ?item .
  #   ?item <http://scta.info/property/hasSurface> ?surface .
  #   ?surface <http://purl.org/dc/elements/1.1/title> ?surface_title .
  #   ?surface <http://scta.info/property/hasISurface> ?isurface .
  #   ?surface <http://scta.info/property/order> ?order .
  #   ?isurface <http://scta.info/property/hasCanvas> ?canvas .
  #   ?canvas <http://www.w3.org/2000/01/rdf-schema#label> ?canvas_label .
  #   ?canvas <http://www.w3.org/2003/12/exif/ns#width> ?canvas_width .
  #   ?canvas <http://www.w3.org/2003/12/exif/ns#height> ?canvas_height .
  #   ?canvas <http://iiif.io/api/presentation/2#hasImageAnnotations> ?bn .
  #   ?bn <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?anno .
  #   ?anno <http://www.w3.org/ns/oa#hasBody> ?resource .
  #   ?resource <http://www.w3.org/2003/12/exif/ns#height> ?image_height .
  #   ?resource <http://www.w3.org/2003/12/exif/ns#width> ?image_width .
  #   ?resource <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?image_type .
  #   ?resource <http://purl.org/dc/elements/1.1/format> ?image_format .
  #   ?resource <http://rdfs.org/sioc/services#has_service> ?image_service .
  #   OPTIONAL{
  #     ?image_service <http://usefulinc.com/ns/doap#implements> ?image_service_profile .
  #   }
  #   OPTIONAL{
  #     ?image_service <http://purl.org/dc/terms/conformsTo> ?image_service_profile .
  #   }
  # }
  # ORDER BY ?order
  # "

query =
"SELECT ?surface ?surface_title ?isurface ?canvas ?canvas_label ?canvas_width ?canvas_height ?image_height ?image_width ?image_type ?image_format ?image_service ?image_service_profile ?anno ?resource
 {
   <http://scta.info/resource/#{manifestationid}> <http://scta.info/property/hasStructureItem> ?item .
   ?item <http://scta.info/property/hasSurface> ?surface .
   ?surface <http://purl.org/dc/elements/1.1/title> ?surface_title .
   ?surface <http://scta.info/property/hasISurface> ?isurface .
   ?surface <http://scta.info/property/order> ?order .
   ?isurface <http://scta.info/property/hasCanvas> ?canvas .
   ?canvas <http://www.w3.org/2000/01/rdf-schema#label> ?canvas_label .
   ?canvas <http://www.w3.org/2003/12/exif/ns#width> ?canvas_width .
   ?canvas <http://www.w3.org/2003/12/exif/ns#height> ?canvas_height .
   OPTIONAL{
   ?canvas <http://iiif.io/api/presentation/2#hasImageAnnotations> ?bn .
   }
   OPTIONAL{
   ?canvas <http://www.shared-canvas.org/ns/hasImageAnnotations> ?bn .
   }
   ?bn <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?anno .
   ?anno <http://www.w3.org/ns/oa#hasBody> ?resource .
   ?resource <http://www.w3.org/2003/12/exif/ns#height> ?image_height .
   ?resource <http://www.w3.org/2003/12/exif/ns#width> ?image_width .
   ?resource <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?image_type .
   ?resource <http://purl.org/dc/elements/1.1/format> ?image_format .
   OPTIONAL{
     ?resource <http://rdfs.org/sioc/services#has_service> ?image_service .
   }
   OPTIONAL{
     ?resource <http://www.shared-canvas.org/ns/hasRelatedService> ?image_service .
   }
   OPTIONAL{
     ?image_service <http://usefulinc.com/ns/doap#implements> ?image_service_profile .
   }
   OPTIONAL{
     ?image_service <http://purl.org/dc/terms/conformsTo> ?image_service_profile .
   }
 }
 ORDER BY ?order"


  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  canvases = []

  results.uniq!
  previous_canvas = ""
  results.each do |result|
    #this conditional is meant to deal with face-pages canvas, in other words cases where two surfaces have the save canvas
    unless result[:canvas].to_s == previous_canvas
      image_profile = result[:image_service_profile].nil? ? "http://iiif.io/api/image/1/level2.json" : result[:image_service_profile]
      #temporary solution to deal with older context for gallica images
      # not a long term solution
      context = if result[:canvas].to_s.include? "gallica.bnf.fr"
            "http://iiif.io/api/image/1/context.json"
          elsif result[:canvas].to_s.include? "iiif.lib.harvard.edu"
            "http://iiif.io/api/image/1/context.json"
          else
            "http://iiif.io/api/image/2/context.json"
        end
      ### end temporary measure.

      canvas = {
        "@id": "#{result[:canvas]}",
        "@type": "sc:Canvas",
        "label": result[:surface_title],
        "height": result[:canvas_height],
        "width": result[:canvas_width],
        "images": [
          {"@id": result[:anno],
            "@type": "oa:Annotation",
            "motivation": "sc:painting",
            "on": "#{result[:canvas]}",
            "resource": {
              "@id": result[:resource],
              "@type": result[:image_type],
              "format": result[:image_format],
              "height": result[:image_height],
              "width": result[:image_width],
              "service": {
                "@context": context,
                "@id": result[:image_service],
                "profile": image_profile
              }
            }
          }
        ],
        "otherContent": [
          {
            #"@id": "http://exist.scta.info/exist/apps/scta-app/folio-annotation-list.xq?surface_id=#{result[:surface].to_s}",
            "@id": "http://scta.info/iiif/#{manifestationid}/list/transcription/#{result[:surface_title]}",
            "@type": "sc:AnnotationList"
          }
        ]
      }

      canvases << canvas
    end
    previous_canvas = result[:canvas]

  end

  manifest = {
    "@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "http://scta.info/iiif/#{manifestationid}/manifest",
    "@type": "sc:Manifest",
    "label": manifestationid,

    "description": "Manifest Description",
    "license": "https://creativecommons.org/publicdomain/zero/1.0/",
    "service": {
      "@context": "http://iiif.io/api/search/1/context.json",
      "@id": "http://exist.scta.info/exist/apps/scta-app/iiif/#{manifestationid}/search",
      "profile": "http://iiif.io/api/search/1/search",
      "label": "Search within this manifest"
    },
    "sequences": [
      {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "http://scta.info/iiif/#{manifestationid}/sequence/normal",
        "@type": "sc:Sequence",
        "label": "Current page order",
        "viewingDirection": "left-to-right",
        "viewingHint": "paged",
        "canvases": canvases
      }
    ],
    "structures": create_range(manifestationid)
  }

  JSON.pretty_generate(manifest)

end
def create_custom_manifest(shortid)
  query = "
  SELECT ?top_level ?top_level_title ?surface ?surface_title ?isurface ?canvas ?canvas_label ?canvas_width ?canvas_height ?image_height ?image_width ?image_type ?image_format ?image_service ?image_service_profile ?anno ?resource
  {
    ?quote <http://scta.info/property/structureType> <http://scta.info/resource/structureElement> .
  	?quote <http://scta.info/property/isInstanceOf> <http://scta.info/resource/#{shortid}> .
  	?quote <http://scta.info/property/isPartOfStructureBlock> ?paragraph .
    ?paragraph <http://scta.info/property/isPartOfTopLevelExpression> ?top_level .
    ?top_level <http://purl.org/dc/elements/1.1/title> ?top_level_title .
  	?paragraph <http://scta.info/property/hasManifestation> ?manifestation .
    ?manifestation <http://scta.info/property/hasSurface> ?surface .
    ?surface <http://purl.org/dc/elements/1.1/title> ?surface_title .
    ?surface <http://scta.info/property/hasISurface> ?isurface .
    ?surface <http://scta.info/property/order> ?order .
    ?isurface <http://scta.info/property/hasCanvas> ?canvas .
    ?canvas <http://www.w3.org/2000/01/rdf-schema#label> ?canvas_label .
    ?canvas <http://www.w3.org/2003/12/exif/ns#width> ?canvas_width .
    ?canvas <http://www.w3.org/2003/12/exif/ns#height> ?canvas_height .
    OPTIONAL{
    ?canvas <http://iiif.io/api/presentation/2#hasImageAnnotations> ?bn .
    }
    OPTIONAL{
    ?canvas <http://www.shared-canvas.org/ns/hasImageAnnotations> ?bn .
    }
    ?bn <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?anno .
    ?anno <http://www.w3.org/ns/oa#hasBody> ?resource .
    ?resource <http://www.w3.org/2003/12/exif/ns#height> ?image_height .
    ?resource <http://www.w3.org/2003/12/exif/ns#width> ?image_width .
    ?resource <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?image_type .
    ?resource <http://purl.org/dc/elements/1.1/format> ?image_format .
    OPTIONAL{
      ?resource <http://rdfs.org/sioc/services#has_service> ?image_service .
    }
    OPTIONAL{
      ?resource <http://www.shared-canvas.org/ns/hasRelatedService> ?image_service .
    }
    OPTIONAL{
      ?image_service <http://usefulinc.com/ns/doap#implements> ?image_service_profile .
    }
    OPTIONAL{
      ?image_service <http://purl.org/dc/terms/conformsTo> ?image_service_profile .
    }
  }
  ORDER BY ?top_level
  "


  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  canvases = []
  results.uniq!
  results.each do |result|
    image_profile = result[:image_service_profile].nil? ? "http://iiif.io/api/image/1/level2.json" : result[:image_service_profile]
    #temporary solution to deal with older context for gallica images
    # not a long term solution
    context = if result[:canvas].to_s.include? "gallica.bnf.fr"
          "http://iiif.io/api/image/1/context.json"
        elsif result[:canvas].to_s.include? "iiif.lib.harvard.edu"
          "http://iiif.io/api/image/1/context.json"
        else
          "http://iiif.io/api/image/2/context.json"
      end
    ### end temporary measure.

    canvas = {
      "@id": "#{result[:canvas]}",
      "@type": "sc:Canvas",
      "label": "#{result[:canvas_label]} - #{result[:top_level_title]}",
      "height": result[:canvas_height],
      "width": result[:canvas_width],
      "images": [
        {"@id": result[:anno],
          "@type": "oa:Annotation",
          "motivation": "sc:painting",
          "on": "#{result[:canvas]}",
          "resource": {
            "@id": result[:resource],
            "@type": result[:image_type],
            "format": result[:image_format],
            "height": result[:image_height],
            "width": result[:image_width],
            "service": {
              "@context": context,
              "@id": result[:image_service],
              "profile": image_profile
            }
          }
        }
      ]
    }

    canvases << canvas

  end

  manifest = {
    "@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "http://scta.info/iiif/custom/manifest",
    "@type": "sc:Manifest",
    "label": "custom query generated manifest for #{shortid}",

    "description": "custom query generated manifest showing canvases with instances of http://scta.info/resource/#{shortid}",
    "license": "https://creativecommons.org/publicdomain/zero/1.0/",
    "sequences": [
      {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "http://scta.info/iiif/custom/sequence/normal",
        "@type": "sc:Sequence",
        "label": "Current page order",
        "viewingDirection": "left-to-right",
        "viewingHint": "paged",
        "canvases": canvases
      }
    ]
  }

  JSON.pretty_generate(manifest)

end
