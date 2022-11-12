module Platform

	KLASSES = {}

	def self.add_to_types(id, klass)
		KLASSES[id] = klass
	end

	module Type
		TABLEAU = Platform.add_to_types(1, Tableau)
		SHODAN  = Platform.add_to_types(2, Shodan)
	end
end
