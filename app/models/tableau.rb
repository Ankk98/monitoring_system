class Tableau
	BASE_URL = "https://public.tableau.com/api"
	QUERY_URL = BASE_URL + "/search/query"

	def self.send_request(params)
		headers = { 'Accept' => 'application/json' }
		HTTParty.get(QUERY_URL, :headers => headers, :query => params)
	end

	def self.get_queries
		[{:query => "ankit", :type => "vizzes"}]
	end

	def self.handle_query(query)
		#last checked at for each query type
		# Can be made async
		# get counts
		# request in loops to fetch reords
		#
		params = {:count => 100, :language => "en-us", :query => query, "type" => type}
		response = send_request(params)
		code = response.code
		if code == 200
			handle_response(response.parsed_response)
		else
			error_msg = response.parsed_response.dig("error")
			logger.error "REQUEST_FAILED: #{code} - #{error_msg}"
		end
	end

	def self.handle_response(resp)
	end

	def self.send_alert
		AlertMailer.new_entries_alert.deliver_now
	end

	def self.monitor(logger)
		logger.info "Monitoring Tableau"
		get_queries.each { |query|
			handle_query(query)
			# send alert
		}
	end
end
