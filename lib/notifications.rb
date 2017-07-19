

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
    manifest = "https://scta.info/iiif/#{manifestationid}/manifest"
  end

  if type == "rangelist"
    all_ranges = create_range(manifestationid)
    final_object =
        {
          "@id": "https://scta.info/iiif/#{manifestationid}/notification/ranges/toc",
          "@type": "Announce",
          "target": [manifest],
          "source": "http://scta.info",
          "updated": Time.now.getutc,
          # "object": {
          #     "@id": "http://scta.info/iiif/#{manifestationid}/ranges/toc/wrapper",
          #     "@type": "sc:Range",
          #     "label": "#{manifestationid}",
          #     "viewingHint": "wrapper",
          #     "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
          #     "description": "A range list for Sentences Commentary #{manifestationid}",
          #     "logo": "http://scta.info/logo.png",
          #     "license": "https://creativecommons.org/publicdomain/zero/1.0/",
          #     "ranges": all_ranges
          #   }
          "object": "https://scta.info/iiif/#{manifestationid}/ranges/toc/wrapper"
        }


  elsif type == "searchwithin"
    service = create_searchwithin(manifestationid)
    final_object = {
      "@id": "https://scta.info/iiif/#{manifestationid}/notification/service/searchwithin",
      "@type": "Announce",
      "target": [manifest],
      "source": "http://scta.info",
      "updated": Time.now.getutc,
      #"object": service
      "object": "https://scta.info/iiif/#{manifestationid}/service/searchwithin"
    }

  elsif type == "layerTranscription"
    transcription_layer = "https://scta.info/iiif/#{manifestationid}/layer/transcription"
    final_object = {
      "@id": "https://scta.info/iiif/#{manifestationid}/notification/layer/transcription",
      "@type": "Announce",
      "target": [manifest],
      "source": "http://scta.info",
      "updated": Time.now.getutc,
      "object": transcription_layer
    }
  end

      JSON.pretty_generate(final_object)

end
