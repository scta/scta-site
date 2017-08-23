

def create_notification (manifestationid, type)

  # this query could be be made more efficient if database contained logical connectors between top level manifestation and codex
  # because these connectios are lacking, the query must go to the item and the surface level first in order to go back up to the codex
  query = "
          SELECT ?manifestOfficial
          {
          <http://scta.info/resource/#{manifestationid}> <http://scta.info/property/hasStructureItem> ?item .
          ?item <http://scta.info/property/hasSurface> ?surface .
          ?codex <http://scta.info/property/hasSurface> ?surface .
          ?codex <http://scta.info/property/hasCodexItem> ?codexItem .
          ?codexItem <http://scta.info/property/hasOfficialManifest> ?manifestOfficial .
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
        "@context": "https://iiif.io/api/presentation/2/context.json",
        "@type": "Announce",
        "motivation": "supplementing",
        "published": Time.now.getutc,
        "actor": {
          "@id": "https://scta.info",
          "label": "SCTA"
        },
        "target": manifest,
        "object": {
          "@id": "https://scta.info/iiif/#{manifestationid}/ranges/toc/wrapper",
          "@type": "sc:Range",
          "attribution": "Data provided by the Scholastic Commentaries and Texts Archive",
          "description": "A Table of Contents for #{manifestationid}",
          "license": "https://creativecommons.org/licenses/by-sa/4.0/",
          "logo": "https://scta.info/logo.png"
        }
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
