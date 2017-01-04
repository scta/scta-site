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
    "dts:members": add_members(resource)
  }

  JSON.pretty_generate(output)
end

def add_members(resource)
  members = []
  if resource.respond_to? :has_parts
    members << dts_parts(resource)
  end
  if resource.respond_to? :expressions
    members << dts_expressions(resource)
  end
  if resource.respond_to? :manifestations
    members << dts_manifestations(resource)
  end
  if resource.respond_to? :transcriptions
    members << dts_transcriptions(resource)
  end
  return members
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
  part_members = {
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
    "dts:members": parts
  }
  return part_members
end

def dts_manifestations(resource)
  manifestations = []
  resource.manifestations.each do |m|
    object = {
      "@id": "http://scta.info/dts?resourceid=#{m.to_s}",
      "canonical_id": m.to_s,
      "rdf:type": "http://scta.info/resource/manifestation",
      "dts:model": "http://w3id.org/dts-ontology/collection"
    }
    manifestations << object
  end
  manifestation_members = {
    "@id": "http://scta.info/dts?resourceid=#{resource.url}#manifestations",
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
    "dts:members": manifestations
  }
  return manifestation_members
end

def dts_transcriptions(resource)
  transcriptions = []
  resource.transcriptions.each do |m|
    object = {
      "@id": "http://scta.info/dts?resourceid=#{m.to_s}",
      "canonical_id": m.to_s,
      "rdf:type": "http://scta.info/resource/transcription",
      "dts:model": "http://w3id.org/dts-ontology/collection"
    }
    transcriptions << object
  end
  transcription_members = {
    "@id": "http://scta.info/dts?resourceid=#{resource.url}#transcriptions",
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
    "dts:members": transcriptions
  }
  return transcription_members
end

def dts_expressions(resource)
  expressions = []
  resource.expressions.each do |m|
    object = {
      "@id": "http://scta.info/dts?resourceid=#{m.to_s}",
      "canonical_id": m.to_s,
      "rdf:type": "http://scta.info/resource/transcription",
      "dts:model": "http://w3id.org/dts-ontology/collection"
    }
    expressions << object
  end
  expression_members = {
    "@id": "http://scta.info/dts?resourceid=#{resource.url}#expressions",
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
    "dts:members": expressions
  }
  return expression_members
end
