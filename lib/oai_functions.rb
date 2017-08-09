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
        <identifier>oai:arXiv.org:cs/0112017</identifier>
        <datestamp>2001-12-14</datestamp>
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
          <dc:subject>Digital Libraries</dc:subject>
          <dc:description>Dublin core description
          </dc:description>
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
  content = "<ListIdentifiers>
    <header>
      <identifier>http://scta.info/resource/plaoulcommentary</identifier>
    </header>
    <!--
    <header>
      <identifier>oai:arXiv.org:hep-th/9801002</identifier>
      <datestamp>1999-03-20</datestamp>
      <setSpec>physic:hep</setSpec>
      <setSpec>physic:exp</setSpec>
    </header>
    <header>
      <identifier>oai:arXiv.org:hep-th/9801005</identifier>
      <datestamp>2000-01-18</datestamp>
      <setSpec>physic:hep</setSpec>
    </header>
    <header status='deleted'>
      <identifier>oai:arXiv.org:hep-th/9801010</identifier>
      <datestamp>1999-02-23</datestamp>
      <setSpec>physic:hep</setSpec>
      <setSpec>math</setSpec>
    </header>
    <resumptionToken expirationDate='2002-06-01T23:20:00Z'
      completeListSize='6'
      cursor='0'>xxx45abttyz</resumptionToken>
      -->
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
def list_records
  content = "<ListRecords>
    <record>
      <header>
        <identifier>oai:arXiv.org:cs/0112017</identifier>
        <datestamp>2001-12-14</datestamp>
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
          <dc:subject>Digital Libraries</dc:subject>
          <dc:description>Dublin core description
          </dc:description>
          <dc:date>2001-12-14</dc:date>
        </oai_dc:dc>
      </metadata>
    </record>
    <!-- more records can be added here -->
  </listRecords>"
end
def list_sets
  content = "<ListSets>
  <!-- set sepcs defined below; i think this is away of defining sub collections
    <set>
      <setSpec>music</setSpec>
      <setName>Music collection</setName>
    </set>
    <set>
      <setSpec>music:(muzak)</setSpec>
      <setName>Muzak collection</setName>
    </set>
    <set>
      <setSpec>music:(elec)</setSpec>
      <setName>Electronic Music Collection</setName>
      <setDescription>
        <oai_dc:dc
          xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/'
          xmlns:dc='http://purl.org/dc/elements/1.1/'
          xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
          xsi:schemaLocation='http://www.openarchives.org/OAI/2.0/oai_dc/
          http://www.openarchives.org/OAI/2.0/oai_dc.xsd'>
          <dc:description>This set contains metadata describing
            electronic music recordings made during the 1950ies
          </dc:description>
        </oai_dc:dc>
      </setDescription>
    </set>
    <set>
      <setSpec>video</setSpec>
      <setName>Video Collection</setName>
    </set> -->
  </ListSets>"

end
