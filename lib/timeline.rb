def create_person_timeline(params)
  orderQuery = ""
  if params[:order]
    orderQuery =  "?person <http://scta.info/property/personType> <http://scta.info/resource/#{params[:order]}> ."
  end
  query = "
  SELECT ?person ?personTitle ?dateOfBirth ?dateOfDeath ?description ?order
  {
    ?person a <http://scta.info/resource/person> .
    ?person <http://scta.info/property/personType> <http://scta.info/resource/scholastic> .
    #{orderQuery}
    ?person <http://purl.org/dc/elements/1.1/title> ?personTitle .
    ?person <http://scta.info/property/dateOfBirth> ?dateOfBirth .
    ?person <http://scta.info/property/dateOfDeath> ?dateOfDeath .
    ?person <http://purl.org/dc/elements/1.1/description> ?description .
    OPTIONAL{
      ?person <http://scta.info/property/order> ?order .
     }
  }
  "

  query_obj = Lbp::Query.new()
  results = query_obj.query(query)
  events = []
  results.each do |event|

      item = {
          "start_date": {
            "year": event[:dateOfBirth],
            "month": "",
            "day": "",
            "hour": "",
            "minute": "",
            "second": "",
            "millisecond": "",
            "format": ""
          },
          "end_date": {
            "year": event[:dateOfDeath],
            "month": "",
            "day": "",
            "hour": "",
            "minute": "",
            "second": "",
            "millisecond": "",
            "format": ""
          },
          "text": {
            "headline": event[:personTitle].to_s + " (" + event[:dateOfBirth] + "-" + event[:dateOfDeath] + ")",
            "text": event[:description].to_s
          }
        }
      events << item
    end

    timeline = {
      "scale": "human",
      "title": {
        "text": {
          "headline": "Scholasticron",
          "text": "<p>A timeline of scholasticism<\/p>"
        }
      },
      "events": events
    }

  JSON.pretty_generate(timeline)

end
