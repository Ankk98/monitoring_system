module Tableau
	QUERY_URL = "https://public.tableau.com/api/search/query"

	# Results are not in order by Author created_at
	# Author profileName seems to be unique
	# Result types are: WORKBOOKS(vizzes), AUTHORS(authors)
	# Workbook luid seems to be unique:  https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_concepts_luid.htm
	# Count limit is 100

	MAX_ITERATIONS = 100

	module Type
		AUTHORS = "authors"
		VIZZES = "vizzes"
	end

	def self.send_request(query, type, start)
		params = {:count => 100, :language => "en-us", :query => query, "type" => type, :start => start}
		resp = RequestModule.send_request(QUERY_URL, params)

		if 200 != resp.code
			logger.error "REQUEST_FAILED: #{resp.code} - #{resp["error"]}"
			raise "REQUEST_FAILED: #{resp.code} - #{resp["error"]}"
		end
		resp
	end

	def self.extract_ids(resp, type)
		results = resp["results"]
		if Type::VIZZES == type
			results.collect { |result| result["workbook"]["luid"] }
		elsif Type::AUTHORS == type
			results.collect { |result| result["author"]["profileName"] }
		else
			raise "Incorrect Type"
		end
	end

	def self.fetch_results(params, logger)
		query = params["query"]
		type = params["type"]
		start = 0
		resp = send_request(query, type, start)

		total_hits = resp["totalHits"]
		vizzes_count = resp["facets"]["entity_type"]["vizzes"]
		authors_count = resp["facets"]["entity_type"]["authors"]
		logger.info "STATS: #{total_hits} : #{vizzes_count} : #{authors_count}"

		ids = extract_ids(resp, type)

		iterations = 0
		while(ids.size < total_hits && MAX_ITERATIONS < iterations)
			logger.info "FETCHING_DATA: #{ids.size} : #{iterations}"
			resp = send_request(query, type, ids.size + 1)
			ids += extract_ids(resp, type)
			iterations += 1
		end
		logger.error "REACHED_MAX_ITERATIONS" if iterations >= MAX_ITERATIONS

		result = {Type::VIZZES => [], Type::AUTHORS => []}
		result[Type::VIZZES] = ids if type == Type::VIZZES
		result[Type::AUTHORS] = ids if type == Type::AUTHORS
		result
	end

	def self.found_new_results?(old, new)
		(new[Type::VIZZES] - old[Type::VIZZES]).any? || (new[Type::AUTHORS] - old[Type::AUTHORS]).any?
	end
end
