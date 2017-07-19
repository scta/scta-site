require_relative "manifests"

def create_wg_collection(wg_shortid)
  query = "
  SELECT ?expression ?expression_shortid ?expression_label ?wg_label
  {
    <http://scta.info/resource/#{wg_shortid}> <http://scta.info/property/hasExpression> ?expression .
    <http://scta.info/resource/#{wg_shortid}> <http://purl.org/dc/elements/1.1/title> ?wg_label .
    ?expression <http://purl.org/dc/elements/1.1/title> ?expression_label .
    ?expression <http://scta.info/property/shortId> ?expression_shortid .
  }
  "

  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  expressions = []
  results.each do |result|
    expression = {
        "@id": "https://scta.info/iiif/#{result[:expression_shortid]}/collection",
        "@type": "sc:Collection",
        "label": result[:expression_label]
      }
    expressions << expression
  end


  collection = {
    "@id": "https://scta.info/iiif/#{wg_shortid}/collection",
    "@type": "sc:Collection",
    "label": results[0][:wg_label],
    "collections": expressions
  }
  JSON.pretty_generate(collection)
end

def create_collection(expressionid)
  query = "
  SELECT ?m ?m_shortid ?m_label (COUNT(?surface) AS ?count)
  {
    <http://scta.info/resource/#{expressionid}> <http://scta.info/property/hasManifestation> ?m .
    ?m <http://purl.org/dc/elements/1.1/title> ?m_label .
    ?m <http://scta.info/property/shortId> ?m_shortid .
    OPTIONAL
    {
      ?m <http://scta.info/property/hasStructureItem> ?item .
      ?item <http://scta.info/property/hasSurface> ?surface .
    }
  }
  GROUP BY ?m_shortid ?m ?m_label
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  manifests = []
  idbase = "https://scta.info"
  results.each do |result|
    #temporary conditional to weed out, born-digital manifestations; should be using a manifestationType property
    unless result[:m_shortid].to_s.include? "critical"
      if result[:count] < 1
        # TODO this string parsing - split() is bad!!!, value should be retrievable from query
        manifestid = get_official_manifest_url(result[:m_shortid].to_s.split("/").last)
        manifestid = if manifestid == "http://localhost:3030/ds/data?default" then "#{idbase}/iiif/#{result[:m_shortid]}/manifest" else manifestid end
        manifest = {
          "@id": manifestid,
          "@type": "sc:Manifest",
          "label": result[:m_label]
        }
      else
        manifest = {
        "@id": "#{idbase}/iiif/#{result[:m_shortid]}/manifest",
        "@type": "sc:Manifest",
        "label": result[:m_label]
        }
      end
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
  SELECT ?m ?m_shortid ?m_label (COUNT(?surface) AS ?count)
  {
    ?expression <http://www.loc.gov/loc.terms/relators/AUT> <http://scta.info/resource/#{personid}> .
    ?expression <http://scta.info/property/level> '1' .
    ?expression <http://scta.info/property/hasManifestation> ?m .
    ?m <http://purl.org/dc/elements/1.1/title> ?m_label .
    ?m <http://scta.info/property/shortId> ?m_shortid .
    OPTIONAL
    {
      ?m <http://scta.info/property/hasStructureItem> ?item .
      ?item <http://scta.info/property/hasSurface> ?surface .
    }
  }
  GROUP BY ?m_shortid ?m ?m_label
  "
  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)

  manifests = []
  idbase = "https://scta.info"


  results.each do |result|
    #temporary conditional to weed out, born-digital manifestations; should be using a manifestationType property
    unless result[:m_shortid].to_s.include? "critical"
      if result[:count] < 1
        # TODO this string parsing - split() is bad!!!, value should be retrievable from query
        manifestid = get_official_manifest_url(result[:m_shortid].to_s.split("/").last)
        manifestid = if manifestid == "http://localhost:3030/ds/data?default" then "#{idbase}/iiif/#{result[:m_shortid]}/manifest" else manifestid end
        manifest = {
          "@id": manifestid,
          "@type": "sc:Manifest",
          "label": result[:m_label]
        }
      else
        manifest = {
        "@id": "#{idbase}/iiif/#{result[:m_shortid]}/manifest",
        "@type": "sc:Manifest",
        "label": result[:m_label]
      }
      end

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
