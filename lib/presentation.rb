def create_presentation_api_1(resource)

  rdfurl = "http://scta.info/resource/#{resource}"

  query = "
  SELECT ?title ?author_title ?item ?item_shortId ?item_title ?canonicalManifestation ?cm_shortId ?canonicalTranscription ?ct_shortId ?file_path
  {
    <#{rdfurl}> <http://purl.org/dc/elements/1.1/title> ?title .
    <#{rdfurl}> <http://www.loc.gov/loc.terms/relators/AUT> ?author .
    ?author <http://purl.org/dc/elements/1.1/title> ?author_title .
    <#{rdfurl}> <http://scta.info/property/hasStructureItem> ?item .
    ?item <http://purl.org/dc/elements/1.1/title> ?item_title .
    ?item <http://scta.info/property/shortId> ?item_shortId .
    ?item <http://scta.info/property/hasCanonicalManifestation> ?canonicalManifestation .
    ?canonicalManifestation <http://scta.info/property/hasCanonicalTranscription> ?canonicalTranscription .
    ?canonicalManifestation <http://scta.info/property/shortId> ?cm_shortId .
    ?canonicalTranscription <http://scta.info/property/hasXML> ?file_path .
    ?canonicalTranscription <http://scta.info/property/shortId> ?ct_shortId .
  }"

  query_obj = Lbp::Query.new()
  results = query_obj.query(query)



  items = results.map do |item|
    {
      "@id": "http://scta.info/presentation/1.0/#{item.item_shortId}",
      "canonicalId": item,
      "type": "expression",
      "title": item.item_title,
      "canonicalManifestation": {
        "@id": "http://scta.info/api/presentation/1.0/#{item.cm_shortId}",
        "canonicalId": item.canonicalManifestation,
        "type": "manifestation",
        "canonicalTranscription": {
          "@id": "http://scta.info/api/presentation/1.0/#{item.ct_shortId}",
          "canonicalId": item.canonicalTranscription,
          "service": {
            "@id": item.file_path.to_s.gsub("http", "https"),
            "format": "appplication/xml"
          }
        }
      }
    }
  end
  response = {
    "@id": "http://scta.info/api/presentation/1.0/#{resource}",
    "canonicalId": "http://scta.info/resource/#{resource}",
    "@type": "expression",
    "title": results[0].title,
    "author": results[0].author_title,
    "items": items
  }
  JSON.pretty_generate(response)
end
