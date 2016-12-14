def dts_output(resource)
  output = {
    "@id": "http://scta.info/dts?resourceid=#{resource.short_id}",
    "canonical_id": resource.url,
    "dts:capabilities": {
      "dts:ordered": false,
      "dts:static": true,
      "dts:navigation": {
        "dts:parents": [
          {
            "@id": "http://scta.info/dts?resourceid=#{resource.is_part_of.to_s}",
            "rdf:type": "[to be added]",
            "dts:model": "http://w3id.org/dts-ontology/collection"
          }
        ],
        "dts:siblings": {}
      }
    },
    "dts:properties": {
      "rdf:type": resource.type,
      "dc:license": "https://creativecommons.org/licenses/by-sa/3.0/"
    },
    "dts:description": [
      {
        "dc:title": resource.title,
        "dc:description": resource.description
      }
    ],
    "dts:members": [
      {
        "@id": "http://scta.info/dts?resourceid=#{resource.url}#parts",
        "dts:capabilities": {
          "dts:ordered": false,
          "dts:supportsRole": false,
          "dts:static": true,
          "dts:navigation": {
            "dts:parents": [
              {
                "@id": "http://scta.info/dts?resourceid=#{resource.url}",
                "canonical_id": resource.url,
                "rdf:type": resource.type.to_s,
                "dts:model": "http://w3id.org/dts-ontology/collection"
              }
            ],
            "dts:siblings": {}
          }
        },
        "dts:properties": {
          "rdf:type": resource.type,
          "dc:license": "https://creativecommons.org/licenses/by-sa/3.0/"
        },
        "dts:description": [
          {
            "dc:title": resource.title,
            "dc:description": resource.description
          }
        ],
        "dts:members": dts_parts(resource)
      }
    ]
  }

  JSON.pretty_generate(output)
end

def dts_parts(resource)
  parts = []
  resource.has_parts.each do |part|
    object = {
      "@id": "http://scta.info/dts?resourceid=#{part.to_s}",
      "canonical_id": part.to_s,
      "rdf:type": "requires more complex query to get this info",
      "dts:model": "http://w3id.org/dts-ontology/collection"
    }
    parts << object
  end
  return parts
end
