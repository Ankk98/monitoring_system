module Platform

	FAILED_COUNT_KEY = "platform_failed_count"
	INTERVAL_SIZE = 5.minute.to_i #TODO: get from conf
	EXPIRY_INTERVAL = 30.minute.to_i
	TOTAL_INTERVALS = 12
	FAIL_THRESHOLD = 5 # TODO: improve

	KLASSES = {}
	TYPES = []
	def self.add_to_types(id, klass)
		KLASSES[id] = klass
		TYPES << id
		id
	end

	module Type
		TABLEAU = Platform.add_to_types(1, Tableau)
		SHODAN  = Platform.add_to_types(2, Shodan)
		#GITLAB  = Platform.add_to_types(2, GitLab)
	end

	def self.get_time_interval(time = Time.current)
		interval = time.to_i % (INTERVAL_SIZE * TOTAL_INTERVALS)
		interval / INTERVAL_SIZE
	end

	def self.get_failed_count_key(type, interval = get_time_interval)
		FAILED_COUNT_KEY + ":" + type.to_s + ":" +  interval.to_s
	end

	def self.incr_platform_failed_count(type, time = Time.current)
		interval = get_time_interval(time)
		key = get_failed_count_key(type, interval)
		if !$redis.get(key).present?
			$redis.setex(key, EXPIRY_INTERVAL, 1)
		else
			$redis.incr(key)
		end
	end

	def self.get_platform_failed_count(type, time = Time.current)
		interval = get_time_interval(time)
		key = get_failed_count_key(type, interval)
		$redis.get(key).to_i
	end
end
