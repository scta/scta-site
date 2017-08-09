def oai_response(params)
  puts params
  verb = params[:verb]
  identifier = params[:identifier]
  metadataPrefix = params[:metadataPrefix]
  new_params = ""
  params.each do |k,v|
    new_params = "#{new_params} #{k}='#{v}'"
  end

  content = if verb == "GetRecord"
    get_record
  elsif verb === "ListIdentifiers"
    list_identifiers
  elsif verb === "ListMetadataFormats"
    list_metadata_formats
  elsif verb === "ListRecords"
    list_records
  elsif verb === "ListSets"
    list_sets
  else
    identify
  end

  response = "<?xml version='1.0' encoding='UTF-8'?>
<OAI-PMH xmlns='http://www.openarchives.org/OAI/2.0/'
  xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
  xsi:schemaLocation='http://www.openarchives.org/OAI/2.0/
  http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd'>
  <responseDate>2002-05-01T19:20:30Z</responseDate>
  <request #{new_params}>https://scta.info/oai</request>
  #{content}
</OAI-PMH> "
end
def get_record
  content = "<GetRecord>
    <record>
      <header>
        <identifier>http://scta.info/resource/plaoulcommentary</identifier>
        <datestamp>2001-12-14</datestamp>
        <setSpec>sententia</setSpec>
      </header>
      <metadata>
        <oai_dc:dc
          xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/'
          xmlns:dc='http://purl.org/dc/elements/1.1/'
          xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
          xsi:schemaLocation='http://www.openarchives.org/OAI/2.0/oai_dc/
          http://www.openarchives.org/OAI/2.0/oai_dc.xsd'>
          <dc:title>Plaoul Commentary</dc:title>
          <dc:creator>Peter Plaoul</dc:creator>
          <dc:description>Dublin core description</dc:description>
          <dc:date>2001-12-14</dc:date>
        </oai_dc:dc>
      </metadata>
    </record>
  </GetRecord>"
  return content
end
def identify
  content = "<Identify>
    <repositoryName>Scholastic Commentaries Text Archive</repositoryName>
    <baseURL>http://scta.info/oai</baseURL>
    <protocolVersion>2.0</protocolVersion>
    <adminEmail>jcwitt@loyola.edu</adminEmail>
    <earliestDatestamp>1990-02-01T12:00:00Z</earliestDatestamp>
    <deletedRecord>transient</deletedRecord>
    <granularity>YYYY-MM-DD</granularity>
  </Identify>"
  return content
end
def list_identifiers
  records = getExpressions("scta")
  combined_records = ""
  records.each do |record|
    record = "<header>
        <identifier>#{record[:expression]}</identifier>
        <datestamp>2001-12-14</datestamp>
        <setSpec>scta</setSpec>
      </header>"
    combined_records = combined_records + record
  end

  content = "<ListIdentifiers>
    #{combined_records}
  </ListIdentifiers>"
  return content
end
def list_metadata_formats
  content = "<ListMetadataFormats>
    <metadataFormat>
      <metadataPrefix>oai_dc</metadataPrefix>
      <schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd
      </schema>
      <metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/
      </metadataNamespace>
    </metadataFormat>
  </ListMetadataFormats>"
  return content
end
def list_records()
  records = getExpressions("scta")
  combined_records = ""
  records.each do |record|
    record = "<record>
      <header>
        <identifier>#{record[:expression]}</identifier>
        <datestamp>2001-12-14</datestamp>
        <setSpec>scta</setSpec>
      </header>
      <metadata>
        <oai_dc:dc
          xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/'
          xmlns:dc='http://purl.org/dc/elements/1.1/'
          xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
          xsi:schemaLocation='http://www.openarchives.org/OAI/2.0/oai_dc/
          http://www.openarchives.org/OAI/2.0/oai_dc.xsd'>
          <dc:title>#{record[:expression_label]}</dc:title>
          <dc:creator>#{record[:author_title]}</dc:creator>
          <dc:description>#{record[:expression_description]}</dc:description>
          <dc:date>2001-12-14</dc:date>
        </oai_dc:dc>
      </metadata>
    </record>"
    combined_records = combined_records + record
  end

  content = "<ListRecords>
    #{combined_records}
  </ListRecords>"
end
def list_sets
  content = "<ListSets>
  <set>
    <setSpec>SCTA</setSpec>
    <setName>Scholastic Commentaries and Texts Archive</setName>
    <setDescription>
    <oai_dc:dc
        xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/'
        xmlns:dc='http://purl.org/dc/elements/1.1/'
        xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
        xsi:schemaLocation='http://www.openarchives.org/OAI/2.0/oai_dc/
        http://www.openarchives.org/OAI/2.0/oai_dc.xsd'>
        <dc:description>Top Level Collection for the Scholastic Commentaries and Texts Archive</dc:description>
     </oai_dc:dc>
  </setDescription>
  </set>
    <set>
      <setSpec>SCTA: (sententia)</setSpec>
      <setName>Sentences Commentaries</setName>
      <setDescription>
      <oai_dc:dc
          xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/'
          xmlns:dc='http://purl.org/dc/elements/1.1/'
          xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
          xsi:schemaLocation='http://www.openarchives.org/OAI/2.0/oai_dc/
          http://www.openarchives.org/OAI/2.0/oai_dc.xsd'>
          <dc:description>A work group for the Sentences Commentary Tradition</dc:description>
       </oai_dc:dc>
    </setDescription>
    </set>
  </ListSets>"
end
# this funciton basically repeats part of create_wg_collection(wg_shortid) in collections.rb;
# TODO: this should be refactored
def getExpressions(wg_shortid)
  query = "
  SELECT ?expression ?expression_shortid ?expression_label ?author_title ?expression_description ?wg_label
  {
    <http://scta.info/resource/#{wg_shortid}> <http://scta.info/property/hasExpression> ?expression .
    <http://scta.info/resource/#{wg_shortid}> <http://purl.org/dc/elements/1.1/title> ?wg_label .
    ?expression <http://purl.org/dc/elements/1.1/title> ?expression_label .
    ?expression <http://www.loc.gov/loc.terms/relators/AUT> ?expression_author .
    ?expression_author <http://purl.org/dc/elements/1.1/title> ?author_title .
    ?expression <http://purl.org/dc/elements/1.1/description> ?expression_description .
    ?expression <http://scta.info/property/shortId> ?expression_shortid .
  }
  "

  #@results = rdf_query(query)
  query_obj = Lbp::Query.new()
  results = query_obj.query(query)
  return results
end
