module RequestModule
	def self.send_request(url, params)
		headers = { 'Accept' => 'application/json' }
		HTTParty.get(url, :headers => headers, :query => params)
	end
end