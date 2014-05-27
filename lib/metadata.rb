class Metadata
	attr_accessor :predicate, :object

	PREFIXES = {
		"http://www.w3.org/2002/07/owl#" => "owl",
		"http://dbpedia.org/ontology/" => "dbpedia",
		"http://purl.org/dc/terms/" => "dcterms",
		"http://purl.org/dc/elements/1.1/" => "dc",
		"http://scta.info/relations/" => "scta-rel",
		"http://scta.info/terms/" => "scta-terms",
		"http://www.loc.gov/loc.terms/relators/" => "role",
		"http://www.w3.org/2001/XMLSchema#" => "xsd",
		"http://scta.info/names/" => "scta-names"
	}

	PREFIX_ORDER = %w(dc role dcterms scta-rel owl )

	def initialize(predicate_object_pair)
		self.predicate = predicate_object_pair[:p]
		self.object = predicate_object_pair[:o]

	end

	def object_is_literal?
		is_literal?(object)
	end

	def object_url
		object_string = object.to_s 
		object_string = object_string.gsub('http://scta.info', '')
	end

	def object_with_prefix
		url_to_prefixed_string(object)
	end

	def predicate_position
		PREFIX_ORDER.index(prefix_for_url(predicate)) || PREFIX_ORDER.size
	end

	def predicate_url
		
		# this string replace is makes the link relative rather than absolute
		predicate_string = predicate.to_s 
		predicate_string = predicate_string.gsub('http://scta.info', '') 
		
		
	end
    #get the predicate with prefix (if a prefix declared, otherwise the whole url is returned)
	def predicate_with_prefix
		url_to_prefixed_string(predicate)
	end

	protected

	#checks to see if return value is an RDF::Literal
	def is_literal?(thing)
		thing.is_a? RDF::Literal
	end
	#checks to see if return value is an RDF::URI
	def is_uri?(thing)
		thing.is_a?(RDF::URI)
	end

	# creates the url with a prefix
	def prefixed_url(url)

		url = url.to_s
		
		#loops through each of declared prefix and checks to see if the url in the question has the urlbase that the prefix stands for 
		prefix_pair = PREFIXES.find do |prefix_url, prefix| 
			url.index(prefix_url) == 0
		end
		# if a prefix pair is found it replaces the long form with the prefix form followed by a colon
		if prefix_pair
			url.gsub(prefix_pair[0], "#{prefix_pair[1]}:")
		end
	end

	# gets the prefix for the url
	def prefix_for_url(url)
		if prefix = prefixed_url(url)
			prefix.split(':').first
		end
	end

	#check to see if there is an assigned prefix for this url; if not, the full url is returned
	def url_to_prefixed_string(url)
		
		if is_uri?(url) && prefixed_url = prefixed_url(url) # i think second part of this condition sets the variable prefixed_url
			prefixed_url
		else
			url.to_s
		end
	end

# url.sub('http://scta.info', '')

end