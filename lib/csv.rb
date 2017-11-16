def create_csv_wg_collection(resource)

  collection = resource.expressions.map do |expression|
    {"collection": expression.short_id, url: "http://scta.info/csv/#{expression.short_id}"}
  end
  JSON.pretty_generate(collection)
end
def create_csv_expression_top_level_collection(resource)

  query = "
  SELECT ?item_short_id ?c_transciption ?c_transcription_short_id
  {
    <#{resource.url}> <http://scta.info/property/hasStructureItem> ?item .
    ?item <http://scta.info/property/shortId> ?item_short_id .
    ?item <http://scta.info/property/hasCanonicalManifestation> ?c_manifestation .
    ?c_manifestation <http://scta.info/property/hasCanonicalTranscription> ?c_transcription .
    ?c_transcription <http://scta.info/property/shortId> ?c_transcription_short_id .
  }"
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)
  collection = results.map do |result|
    {"item": result.item_short_id, url: "https://exist.scta.info/exist/apps/scta-app/csv/#{result.c_transcription_short_id}"}
  end
  JSON.pretty_generate(collection)
end
def create_csv(resource)
  if resource.type.to_s == "http://scta.info/resource/workGroup"
    create_csv_wg_collection(resource)
  elsif resource.type.to_s == "http://scta.info/resource/expression"
    create_csv_expression_top_level_collection(resource)
  end
end
