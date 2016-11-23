def create_notification (manifestationid, type)

  query = "
          SELECT ?manifestOfficial
          {
          <http://scta.info/resource/#{manifestationid}> <http://scta.info/property/manifestOfficial> ?manifestOfficial .
          }
          "
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)
  if results[0] != nil
    manifest = results[0][:manifestOfficial].to_s
  else
    manifest = "http://scta.info/iiif/#{manifestationid}/manifest"
  end

  if type == "rangelist"
    all_ranges = create_range(manifestationid)
    final_object =
        {
          "@id": "http://scta.info/iiif/#{manifestationid}/notification/ranges/toc",
          "@type": "Announce",
          "target": [manifest],
          "updated": "",
          "object": {
              "@id": "http://scta.info/iiif/rothwellcommentary/wettf15/ranges/toc/wrapper",
              "@type": "sc:Range",
              "label": "#{manifestationid}",
              "viewingHint": "wrapper",
              "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
              "description": "A range list for Sentences Commentary #{manifestationid}",
              "logo": "http://scta.info/logo.png",
              "license": "https://creativecommons.org/publicdomain/zero/1.0/",
              "ranges": all_ranges
            }
          }


  elsif type == "searchwithin"
    service = create_searchwithin(manifestationid)
    final_object = {
      "@id": "http://scta.info/iiif/#{manifestationid}/notification/service/searchwithin",
      "@type": "Announce",
      "target": [manifest],
      "updated": "",
      "object": service
    }

  elsif type == "layerTranscription"
    transcription_layer = "http://scta.info/iiif/#{manifestationid}/layer/transcription"
    final_object = {
      "@id": "http://scta.info/iiif/#{manifestationid}/notification/layer/transcription",
      "@type": "Announce",
      "target": [manifest],
      "updated": "",
      "object": transcription_layer
    }
  end

      JSON.pretty_generate(final_object)

end
