def create_collection(expressionid)
  query = "
  SELECT ?m ?m_shortid ?m_label
  {
    <http://scta.info/resource/#{expressionid}> <http://scta.info/property/hasManifestation> ?m .
    ?m <http://purl.org/dc/elements/1.1/title> ?m_label .
    ?m <http://scta.info/property/shortId> ?m_shortid .
  }
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  manifests = []
  idbase = "http://scta.info"
  results.each do |result|
    #temporary conditional to weed out, born-digital manifestations; should be using a manifestationType property
    unless result[:m_shortid].to_s.include? "critical"
      manifest = {
        "@id": "#{idbase}/iiif/#{result[:m_shortid]}/manifest",
        "@type": "sc:Manifest",
        "label": result[:m_label]
      }
    manifests << manifest
    end



  end

  collection = {
    "@id": "#{idbase}/iiif/#{expressionid}/collection",
    "@type": "sc:Collection",
    "label": expressionid,
    "manifests": manifests
  }
  JSON.pretty_generate(collection)
end

def create_person_collection(personid)

  query = "
  SELECT ?m ?m_shortid ?m_label
  {
    ?expression <http://www.loc.gov/loc.terms/relators/AUT> <http://scta.info/resource/#{personid}> .
    ?expression <http://scta.info/property/level> '1' .
    ?expression <http://scta.info/property/hasManifestation> ?m .
    ?m <http://purl.org/dc/elements/1.1/title> ?m_label .
    ?m <http://scta.info/property/shortId> ?m_shortid .
  }
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  manifests = []
  idbase = "http://scta.info"


  results.each do |result|
    #temporary conditional to weed out, born-digital manifestations; should be using a manifestationType property
    unless result[:m_shortid].to_s.include? "critical"
      manifest = {
        "@id": "#{idbase}/iiif/#{result[:m_shortid]}/manifest",
        "@type": "sc:Manifest",
        "label": result[:m_label]
      }
    manifests << manifest
    end





  end

  collection = {
    "@id": "#{idbase}/iiif/#{personid}/collection",
    "@type": "sc:Collection",
    "label": personid,
    "manifests": manifests
  }
  JSON.pretty_generate(collection)
end
