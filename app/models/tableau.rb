class Tableau
	BASE_URL = "https://public.tableau.com/api"
	QUERY_URL = BASE_URL + "/search/query"
	
	# Results are not in order by Author created_at
	# Author profileName seems to be unique
	# Result types are: WORKBOOKS(vizzes), AUTHORS(authors)
	# Workbook luid seems to be unique:  https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_concepts_luid.htm
	# Count limit is 100

	TYPES = ["vizzes", "authors"]
	MAX_ITERATIONS = 100


	def fetch_results(query, type, start, logger, iterations = 0)
		raise "Reached Max Allowed Iterations" if iterations == MAX_ITERATIONS

		logger.info "FETCHING_DATA: #{start} : #{iterations}"
		params = {:count => 100, :language => "en-us", :query => query, "type" => type, :start => start}
		resp = RequestModule.send_request(QUERY_URL, params)

		if 200 != resp.code
			error_msg = resp["error"]
			logger.error "REQUEST_FAILED: #{resp.code} - #{error_msg}"
			raise e
		end

		total_hits = resp["totalHits"]
		vizzes_count = resp["facets"]["entity_type"]["vizzes"]
		authors_count = resp["facets"]["entity_type"]["authors"]
		logger.info "STATS: #{total_hits} : #{vizzes_count} : #{authors_count}"
		results = resp["results"]

		if type == "vizzes"
			@vizzes_ids += results.collect { |result| result["workbook"]["luid"] }
		elsif type == "authors"
			@author_ids += results.collect { |result| result["author"]["profileName"] }
		else
			raise "Incorrect Type"
		end

		fetch_results(query, type, start + 100, logger, iterations + 1) if start + results.size < total_hits
	end

	def monitor(action, logger)
		logger.info "MONITORING_TABLEAU_STARTED: #{action.id} - #{action.monitoring_query_id}"
		params = action.monitoring_query.params

		@vizzes_ids = []
		@author_ids = []
		fetch_results(params["query"], params["type"], 0, logger)

		results = {"vizzes" => @vizzes_ids, "authors" => @author_ids}
		prev_action = action.monitoring_query.monitoring_actions.succeeded.last
		if prev_action
			prev_results = prev_action.results
			found_new_results = (@vizzes_ids - prev_results["vizzes"]).any? || (@author_ids - prev_results["authors"]).any?
			logger.info "NEW_SAMPLE: #{@author_ids - prev_results["authors"]}"
		else
			found_new_results = true
		end

		action.update!(:state => MonitoringAction::State::SUCCEEDED, :results => results, :found_new_results => found_new_results)
		logger.info "MONITORING_TABLEQU_ENDED: #{action.id} - #{action.monitoring_query_id}"
	rescue => e
		logger.info "MONITORING_TABLEAU_ERROR: #{action.id} - #{action.monitoring_query_id} : #{e.class} : #{e.message} : #{e.backtrace}"
		action.mark_state(MonitoringAction::State::FAILED)
		# stat
		# store platform failure count in redis with ttl
		raise e
	end
end
