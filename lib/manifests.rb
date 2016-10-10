

def create_manifest()
  query = "
  SELECT ?surface ?surface_title ?isurface ?canvas
  {
    <http://scta.info/resource/quaracchi1924> <http://scta.info/property/hasSurface> ?surface .
    ?surface <http://purl.org/dc/elements/1.1/title> ?surface_title .
    ?surface <http://scta.info/property/hasISurface> ?isurface .
    ?isurface <http://scta.info/property/hasCanvas> ?canvas .
  }
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  canvases = []
  number = 1
  results.each do |result|
    #temp
    if number < 10
      image_number = "00#{number}"
    elsif number < 100
      image_number = "0#{number}"
    elsif number < 1000
      image_number = "#{number}"
    end
    #temp
    canvas = {
      "@id": "#{result[:canvas]}",
      "@type": "sc:Canvas",
      "label": "#{result[:surface_title]}",
      "height": 6496,
      "width": 4872,
      "images": [
        {"@id": "http://scta.info/resource/quaracchi1924/canvas/#{number}/image/#{number}",
          "@type": "oa:Annotation",
          "motivation": "sc:painting",
          "on": "#{result[:canvas]}",
          "resource": {
            "@id": "http://scta.info/resource/quaracchi1924/canvas/#{number}/res/#{image_number}.jpg",
            "@type": "dctypes:Image",
            "format": "image/jpeg",
            "height": 6496,
            "width": 4872,
            "service": {
              "@context": "http://iiif.io/api/image/2/context.json",
              "@id": "http://loris2.scta.info/quaracchi1924/#{image_number}.jpg",
              "profile": "http://library.stanford.edu/iiif/image-api/compliance.html#level1"
            }
          }
        }
      ],
    }


    canvases << canvas
    number = number + 1
  end

  manifest = {
    "@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "http://scta.info/iiif/quaracchi1924/manifest",
    "@type": "sc:Manifest",
    "label": "Manifest Label",
    "metadata": [
      {
        "label": "Author",
        "value": "Alexander de Hales"
      },
      {
        "label": "Published",
        "value": [
          {
            "@language": "la"
          }
        ]
      }
    ],
    "description": "Manifest Description",
    "license": "https://creativecommons.org/publicdomain/zero/1.0/",
    "attribution": "e-codices - Virtual Manuscript Library of Switzerland",
    "seeAlso": "see also link",
    "logo": "http://e-codices.textandbytes.com/img/logo.png",
    "service": {
      "@context": "http://iiif.io/api/search/1/context.json",
      "@id": "http://exist.scta.info/exist/apps/scta/iiif/wdr-wettf15/search",
      "profile": "http://iiif.io/api/search/1/search",
      "label": "Search within this manifest"
    },
    "sequences": [
      {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "http://scta.info/iiif/wdr-wettf15/sequence/normal",
        "@type": "sc:Sequence",
        "label": "Current page order",
        "viewingDirection": "left-to-right",
        "viewingHint": "paged",
        "canvases": canvases
      }
    ],
    "structures": create_range3("quaracchi1924", "summahalensis")
  }

  JSON.pretty_generate(manifest)


end
def create_expression_manifest(expressionid, manifestationid)
  query = "
  SELECT ?surface ?surface_title ?isurface ?canvas
  {
    <http://scta.info/resource/#{expressionid}/#{manifestationid}> <http://scta.info/property/hasStructureItem> ?item .
    ?item <http://scta.info/property/hasSurface> ?surface .
    ?surface <http://purl.org/dc/elements/1.1/title> ?surface_title .
    ?surface <http://scta.info/property/hasISurface> ?isurface .
    ?isurface <http://scta.info/property/hasCanvas> ?canvas .
  }
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  canvases = []
  number = 1
  results.each do |result|
    #temp
    if number < 10
      image_number = "00#{number}"
    elsif number < 100
      image_number = "0#{number}"
    elsif number < 1000
      image_number = "#{number}"
    end
    #temp
    canvas = {
      "@id": "#{result[:canvas]}",
      "@type": "sc:Canvas",
      "label": "#{result[:surface_title]}",
      "height": 6496,
      "width": 4872,
      "images": [
        {"@id": "http://scta.info/resource/quaracchi1924/canvas/#{number}/image/#{number}",
          "@type": "oa:Annotation",
          "motivation": "sc:painting",
          "on": "#{result[:canvas]}",
          "resource": {
            "@id": "http://scta.info/resource/quaracchi1924/canvas/#{number}/res/#{image_number}.jpg",
            "@type": "dctypes:Image",
            "format": "image/jpeg",
            "height": 6496,
            "width": 4872,
            "service": {
              "@context": "http://iiif.io/api/image/2/context.json",
              "@id": "http://loris2.scta.info/quaracchi1924/#{image_number}.jpg",
              "profile": "http://library.stanford.edu/iiif/image-api/compliance.html#level1"
            }
          }
        }
      ],
    }


    canvases << canvas
    number = number + 1
  end

  manifest = {
    "@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "http://scta.info/iiif/quaracchi1924/manifest",
    "@type": "sc:Manifest",
    "label": "Manifest Label",
    "metadata": [
      {
        "label": "Author",
        "value": "Alexander de Hales"
      },
      {
        "label": "Published",
        "value": [
          {
            "@language": "la"
          }
        ]
      }
    ],
    "description": "Manifest Description",
    "license": "https://creativecommons.org/publicdomain/zero/1.0/",
    "attribution": "e-codices - Virtual Manuscript Library of Switzerland",
    "seeAlso": "see also link",
    "logo": "http://e-codices.textandbytes.com/img/logo.png",
    "service": {
      "@context": "http://iiif.io/api/search/1/context.json",
      "@id": "http://exist.scta.info/exist/apps/scta/iiif/wdr-wettf15/search",
      "profile": "http://iiif.io/api/search/1/search",
      "label": "Search within this manifest"
    },
    "sequences": [
      {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "http://scta.info/iiif/wdr-wettf15/sequence/normal",
        "@type": "sc:Sequence",
        "label": "Current page order",
        "viewingDirection": "left-to-right",
        "viewingHint": "paged",
        "canvases": canvases
      }
    ],
    "structures": create_range3("quaracchi1924", "summahalensis")
  }

  JSON.pretty_generate(manifest)

end
