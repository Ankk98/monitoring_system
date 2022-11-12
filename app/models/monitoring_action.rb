class MonitoringAction < ApplicationRecord
	belongs_to :monitoring_query
	serialize :results, JSON

	module State
		INITIALIZED = 1
		RUNNING     = 2
		SUCCEEDED   = 3
		FAILED      = 4
		CANCELLED   = 5
	end

	PENDING_STATES = [State::INITIALIZED, State::RUNNING]
	FINISHED_STATES = [State::SUCCEEDED, State::FAILED, State::CANCELLED]

	scope :succeeded, -> { where(:state => State::SUCCEEDED) }
	scope :pending, -> { where(:state => PENDING_STATES) }
	scope :finished, -> { where.not(:state => FINISHED_STATES) }
	scope :pending_notification, -> { where(:notified => false, :found_new_results => true) }

	def mark_state(_state)
		update!(:state => _state)
	end
end
