module RequestModule
	MAX_RETIES = 2
	def self.send_request(url, params)
		tries ||= 1
		headers = { 'Accept' => 'application/json' }
		HTTParty.get(url, :headers => headers, :query => params)
	rescue => e
		logger.error "HTTP_REQUEST_ERROR: #{e.class} - #{e.message} - #{e.backtrace}"
		tries += 1
		retry if tries < MAX_RETIES
		raise e
	end
end
