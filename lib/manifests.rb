

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
    ?canvas <http://iiif.io/api/presentation/2#hasImageAnnotations> ?bn .
    ?bn <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?anno .
    ?anno <http://www.w3.org/ns/oa#hasBody> ?resource .
    ?resource <http://www.w3.org/2003/12/exif/ns#height> ?image_height .
    ?resource <http://www.w3.org/2003/12/exif/ns#width> ?image_width .
    ?resource <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?image_type .
    ?resource <http://purl.org/dc/elements/1.1/format> ?image_format .
    ?resource <http://rdfs.org/sioc/services#has_service> ?image_service .
    ?image_service <http://usefulinc.com/ns/doap#implements> ?image_service_profile .
  }
  ORDER BY ?order
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  canvases = []
  number = 1
  results.each do |result|


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
              "@context": "http://iiif.io/api/image/2/context.json",
              "@id": result[:image_service],
              "profile": result[:image_service_profile].nil? ? "http://iiif.io/api/image/1/level2.json" : result[:image_service_profile]
            }
          }
        }
      ],
      "otherContent": [
        {
          "@id": "http://localhost:8080/exist/apps/scta-app/folio-annotation-list2.xq?surface_id=#{result[:surface].to_s}",
          "@type": "sc:AnnotationList"
        }
      ]
    }


    canvases << canvas
    number = number + 1
  end

  manifest = {
    "@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "http://scta.info/iiif/#{shortid}/manifest",
    "@type": "sc:Manifest",
    "label": "#{shortid}",
    "description": "Manifest Description",
    "license": "https://creativecommons.org/publicdomain/zero/1.0/",
    "service": {
      "@context": "http://iiif.io/api/search/1/context.json",
      "@id": "http://exist.scta.info/exist/apps/scta/iiif/#{shortid}/search",
      "profile": "http://iiif.io/api/search/1/search",
      "label": "Search within this manifest"
    },
    "sequences": [
      {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "http://scta.info/iiif/#{shortid}/sequence/normal",
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
def create_expression_manifest(manifestationid)
  query = "
  SELECT ?surface ?surface_title ?isurface ?canvas ?canvas_label ?canvas_width ?canvas_height ?image_height ?image_width ?image_type ?image_format ?image_service ?image_service_profile ?anno ?resource
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
    ?canvas <http://iiif.io/api/presentation/2#hasImageAnnotations> ?bn .
    ?bn <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?anno .
    ?anno <http://www.w3.org/ns/oa#hasBody> ?resource .
    ?resource <http://www.w3.org/2003/12/exif/ns#height> ?image_height .
    ?resource <http://www.w3.org/2003/12/exif/ns#width> ?image_width .
    ?resource <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?image_type .
    ?resource <http://purl.org/dc/elements/1.1/format> ?image_format .
    ?resource <http://rdfs.org/sioc/services#has_service> ?image_service .
    ?resource <http://rdfs.org/sioc/services#has_service> ?image_service .
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

  canvases = []
  results.uniq!
  results.each do |result|
    image_profile = result[:image_service_profile].nil? ? "http://iiif.io/api/image/1/level2.json" : result[:image_service_profile]
    #temporary solution to deal with older context for gallica images
    # not a long term solution
    context = if result[:canvas].to_s.include? "gallica.bnf.fr" then "http://iiif.io/api/image/1/context.json" else "http://iiif.io/api/image/2/context.json" end
    ### end temporary measure.

    canvas = {
      "@id": "#{result[:canvas]}",
      "@type": "sc:Canvas",
      "label": result[:canvas_label],
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
          "@id": "http://localhost:8080/exist/apps/scta-app/folio-annotation-list2.xq?surface_id=#{result[:surface].to_s}",
          "@type": "sc:AnnotationList"
        }
      ]
    }

    canvases << canvas

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
      "@id": "http://exist.scta.info/exist/apps/scta/iiif/#{manifestationid}/search",
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
