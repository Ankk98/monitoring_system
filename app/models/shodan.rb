module Shodan
	# How to solve the same count problem?
	QUERY_URL = "https://api.shodan.io/shodan/host/search"
	SHODAN_KEY = YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/shodan.yml")).result)[Rails.env]

	# Assuming that page 1 results are good enough
	def self.fetch_results(params, logger)
		logger.info "FETCHING_DATA"
		_params = {:query => params["query"], :key => SHODAN_KEY}
		resp = RequestModule.send_request(QUERY_URL, _params)

		if 200 != resp.code
			logger.error "REQUEST_FAILED: #{resp.code} - #{resp["error"]}"
			raise "REQUEST_FAILED: #{resp.code} - #{resp["error"]}"
		end

		logger.info "TOTAL: #{resp["total"]}"
		{
			"ids" => resp["matches"].collect { |result| result["_shodan"]["id"] }
		}
	end

	def self.found_new_results?(old, new)
		(new["ids"] - old["ids"]).any?
	end
end
