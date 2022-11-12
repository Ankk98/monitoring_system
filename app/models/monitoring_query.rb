class MonitoringQuery < ApplicationRecord
	has_many :monitoring_actions
	serialize :params, JSON
	# TODO: Enforce structure of params based on platform

	module State
		VALID   = 1
		INVALID = 2
	end

	scope :valid, -> { where(:state => State::VALID) }

	def platform
		Platform::KLASSES[self.platform_id]
	end
end
