
def dts_output(resource)
  output = {
    "@context": {
      "": "http://chs.harvard.edu/xmlns/cts/",
      "dts": "http://w3id.org/dts-ontology/",
      "ns1": "http://purl.org/dc/elements/1.1/",
      "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
      "skos": "http://www.w3.org/2004/02/skos/core#",
      "sctap": "http://scta.info/property/",
      "sctar": "http://scta.info/resource/",
      },
    "@id": resource.url,
    "dts:id": "http://scta.info/dts/collection/#{CGI.escape(resource.url)}",
    "@graph": {
      "dts:metadata": {
          "rdf:type": resource.type,
          "dc:license": "https://creativecommons.org/licenses/by-sa/3.0/",
          "dc:title": resource.title,
          "dc:description": resource.description
        },
      "dts:parents": [
          {
            "@id": "http://scta.info/dts/collection/#{CGI.escape(resource.url)}",
            "rdf:type": "[to be added]",
            "dts:model": "http://w3id.org/dts-ontology/collection"
          }
        ]
      },
      #{}"dts:siblings": {},
      "dts:members": add_members(resource),
    }

  JSON.pretty_generate(output)
end

def add_members(resource)
  members = []
  if resource.respond_to? :has_parts
    if resource.has_parts.count > 0
      members << dts_parts(resource, "part")
    end
  end
  if resource.respond_to? :expressions
    if resource.has_parts.count > 0
      members << dts_parts(resource, "expression")
    end
  end
  if resource.respond_to? :manifestations
    if resource.has_parts.count > 0
      members << dts_parts(resource, "manifestation")
    end
  end
  if resource.respond_to? :transcriptions
    if resource.has_parts.count > 0
      members << dts_parts(resource, "transcription")
    end
  end
  return members
end

def dts_parts(resource, type)
  @type = type
  if type == "part"
    resources = resource.has_parts
  elsif type == "expression"
    resources = resource.expressions
  elsif type == "manifestation"
    resources = resource.manifestations
  elsif type == "transcription"
    resources = resource.transcriptions
  end

  parts = []
  resources.each do |part|

    part = part.resource
    parents = if part.is_part_of
      {
        "@id": part.is_part_of.to_s,
        "dts:url": "http://scta.info/dts/collection/#{CGI.escape(part.is_part_of.url)}",
        "rdf:type": "[to be added]",
        "dts:model": "http://w3id.org/dts-ontology/collection"
      }
    else
      nil
    end

    part_member = {
      "@id": part.url,
      "dts:url": "http://scta.info/dts/collection/#{CGI.escape(part.url)}",
      "dts:role": type,
      "dts:metadata": {
          "rdf:type": part.type,
          "dc:license": "https://creativecommons.org/licenses/by-sa/3.0/",
          "dc:title": part.title,
          "dc:description": part.description
        },
      "dts:parents": [parents]
      #"dts:siblings": {}

      #{}"dts:members": parts
    }
    parts << part_member
  end
  return parts
end
#
# def dts_manifestations(resource)
#   manifestations = []
#   resource.manifestations.each do |m|
#     object = {
#       "@id": "http://scta.info/dts?resourceid=#{m.to_s}",
#       "canonical_id": m.to_s,
#       "rdf:type": "http://scta.info/resource/manifestation",
#       "dts:model": "http://w3id.org/dts-ontology/collection"
#     }
#     manifestations << object
#   end
#   manifestation_members = {
#     "@id": resource.url,
#     "dts:url": "http://scta.info/dts?resourceid=#{resource.url},
#     "dts:capabilities": {
#       "dts:ordered": false,
#       "dts:supportsRole": false,
#       "dts:static": true,
#       "dts:navigation": {
#         "dts:parents": [
#           {
#             "@id": "http://scta.info/dts?resourceid=#{resource.url}",
#             "canonical_id": resource.url,
#             "rdf:type": resource.type.to_s,
#             "dts:model": "http://w3id.org/dts-ontology/collection"
#           }
#         ],
#         "dts:siblings": {}
#       }
#     },
#     "dts:properties": {
#       "rdf:type": resource.type,
#       "dc:license": "https://creativecommons.org/licenses/by-sa/3.0/"
#     },
#     "dts:description": [
#       {
#         "dc:title": resource.title,
#         "dc:description": resource.description
#       }
#     ],
#     "dts:members": manifestations
#   }
#   return manifestation_members
# end
#
# def dts_transcriptions(resource)
#   transcriptions = []
#   resource.transcriptions.each do |m|
#     object = {
#       "@id": "http://scta.info/dts?resourceid=#{m.to_s}",
#       "canonical_id": m.to_s,
#       "rdf:type": "http://scta.info/resource/transcription",
#       "dts:model": "http://w3id.org/dts-ontology/collection"
#     }
#     transcriptions << object
#   end
#   transcription_members = {
#     "@id": "http://scta.info/dts?resourceid=#{resource.url}#transcriptions",
#     "dts:capabilities": {
#       "dts:ordered": false,
#       "dts:supportsRole": false,
#       "dts:static": true,
#       "dts:navigation": {
#         "dts:parents": [
#           {
#             "@id": "http://scta.info/dts?resourceid=#{resource.url}",
#             "canonical_id": resource.url,
#             "rdf:type": resource.type.to_s,
#             "dts:model": "http://w3id.org/dts-ontology/collection"
#           }
#         ],
#         "dts:siblings": {}
#       }
#     },
#     "dts:properties": {
#       "rdf:type": resource.type,
#       "dc:license": "https://creativecommons.org/licenses/by-sa/3.0/"
#     },
#     "dts:description": [
#       {
#         "dc:title": resource.title,
#         "dc:description": resource.description
#       }
#     ],
#     "dts:members": transcriptions
#   }
#   return transcription_members
# end
#
# def dts_expressions(resource)
#   expressions = []
#   resource.expressions.each do |m|
#     object = {
#       "@id": "http://scta.info/dts?resourceid=#{m.to_s}",
#       "canonical_id": m.to_s,
#       "rdf:type": "http://scta.info/resource/transcription",
#       "dts:model": "http://w3id.org/dts-ontology/collection"
#     }
#     expressions << object
#   end
#   expression_members = {
#     "@id": "http://scta.info/dts?resourceid=#{resource.url}#expressions",
#     "dts:capabilities": {
#       "dts:ordered": false,
#       "dts:supportsRole": false,
#       "dts:static": true,
#       "dts:navigation": {
#         "dts:parents": [
#           {
#             "@id": "http://scta.info/dts?resourceid=#{resource.url}",
#             "canonical_id": resource.url,
#             "rdf:type": resource.type.to_s,
#             "dts:model": "http://w3id.org/dts-ontology/collection"
#           }
#         ],
#         "dts:siblings": {}
#       }
#     },
#     "dts:properties": {
#       "rdf:type": resource.type,
#       "dc:license": "https://creativecommons.org/licenses/by-sa/3.0/"
#     },
#     "dts:description": [
#       {
#         "dc:title": resource.title,
#         "dc:description": resource.description
#       }
#     ],
#     "dts:members": expressions
#   }
#   return expression_members
#end
