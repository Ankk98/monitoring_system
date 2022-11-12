class Shodan
	# How to solve the same count problem?
	QUERY_URL = "https://api.shodan.io/shodan/host/search"
	SHODAN_KEY = YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/shodan.yml")).result)[Rails.env]

	# Assuming that page 1 results are good enough
	def fetch_results(query, logger)
		logger.info "FETCHING_DATA"
		params = {:query => query, :key => SHODAN_KEY}
		resp = RequestModule.send_request(QUERY_URL, params)

		if 200 != resp.code
			logger.error "REQUEST_FAILED: #{resp.code} - #{resp.dig("error")}"
			raise e
		end

		logger.info "TOTAL: #{resp["total"]}"
		resp["matches"].collect { |result| result["_shodan"]["id"] }
	end

	def monitor(action, logger)
		logger.info "MONITORING_SHODAN_STARTED: #{action.id} - #{action.monitoring_query_id}"
		params = action.monitoring_query.params

		ids = fetch_results(params["query"], logger)
		results = { "ids" =>  ids}
		prev_action = action.monitoring_query.monitoring_actions.succeeded.last
		found_new_results = true
		if prev_action
			prev_results = prev_action.results
			found_new_results = (ids - prev_results["ids"]).any?
		end

		action.update!(:state => MonitoringAction::State::SUCCEEDED, :results => results, :found_new_results => found_new_results)
		logger.info "MONITORING_SHODAN_ENDED: #{action.id} - #{action.monitoring_query_id}"
	rescue => e
		logger.info "MONITORING_SHODAN_ERROR: #{action.id} - #{action.monitoring_query_id} : #{e.class} : #{e.message} : #{e.backtrace}"
		action.mark_state(MonitoringAction::State::FAILED)
		# stat
		raise e
	end
end
