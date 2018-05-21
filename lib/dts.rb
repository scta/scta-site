
def dts_output(resource, baseurl)
  output = {
    "@context": {
      "@vocab": "https://www.w3.org/ns/hydra/core#",
      "dc": "http://purl.org/dc/terms/",
      "dts": "https://w3id.org/dts/api#",
      "tei": "http://www.tei-c.org/ns/1.0",
      "sctap": "http://scta.info/property/",
      "sctar": "http://scta.info/resource/",
      },
    "@type": "collection",
    "@id": resource.url,
    "dtsuri": "#{baseurl}/dts/collections?resourceid=" + resource.url,
    "totalItems": resource.has_parts.count,
    "member": add_members(resource, baseurl),
    }

  JSON.pretty_generate(output)
end

def add_members(resource, baseurl)
  members = []
  if resource.respond_to? :has_parts
    if resource.has_parts.count > 0
      members << dts_parts(resource, "part", baseurl)
    end
  end
  if resource.respond_to? :expressions
    if resource.has_parts.count > 0
      members << dts_parts(resource, "expression", baseurl)
    end
  end
  if resource.respond_to? :manifestations
    if resource.has_parts.count > 0
      members << dts_parts(resource, "manifestation", baseurl)
    end
  end
  if resource.respond_to? :transcriptions
    if resource.has_parts.count > 0
      members << dts_parts(resource, "transcription", baseurl)
    end
  end
  return members
end

def dts_parts(resource, type, baseurl)
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
    if part.value("http://scta.info/property/structureType").to_s == "http://scta.info/resource/structureItem"
      part_member = part_item(part, baseurl)
    else
      part_member = part_collection(part, baseurl)
    end
    parts << part_member
  end
  return parts
end

def part_item (part, baseurl)
  part_member = {
    "@id": part.url,
    "@type": "resource",
    "dtsuri": "#{baseurl}/dts/collections?resourceid=" + part.url,
    "title": part.title,
    "dts:dublincore":{
        "dc:license": "https://creativecommons.org/licenses/by-nc-sa/4.0/",
        "dc:title": part.title,
        "dc:description": part.description
      },
    "dts:passage": "/api/dts/documents?id=#{part.url}",
    "dts:references": "/api/dts/navigation?id=#{part.url}",
    "dts:download": get_xml_address(part),
    "tei:refsDecl": [
        {
            "tei:matchPattern":  "(\\w+)",
            "tei:replacementPattern": "#xpath(/tei:TEI/tei:text/tei:body/tei:div/tei:div[@n='$1'])",
            "@type": "paragraph"
        },
    ]
  }
end
def part_collection(part, baseurl)
  part_member = {
    "@id": part.url,
    "@type": "collection",
    "dtsuri": "#{baseurl}/dts/collections?resourceid=" + part.url,
    "title": part.title,
    "dts:dublincore":{
        "dc:license": "https://creativecommons.org/licenses/by-nc-sa/4.0/",
        "dc:title": part.title,
        "dc:description": part.description
      },
      "totalItems": part.has_parts.count
    }
end

def get_xml_address (resource)
  if resource.type.short_id == "expression" || resource.type.short_id == "manifestation"
    transcription = resource.canonical_transcription.resource
  elsif resource.type.short_id == "transcription"
    transcription = resource
  end

  xmldoc = transcription.value("http://scta.info/property/hasXML")
  return xmldoc

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
