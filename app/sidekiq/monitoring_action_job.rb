class MonitoringActionJob
	include Sidekiq::Job

	def perform(action_id)
		logger.info "STARTED_MONITORING_ACTION_JOB: #{action_id}"
		action = MonitoringAction.find(action_id)
		action.mark_state(MonitoringAction::State::RUNNING)

		platform = action.monitoring_query.platform
		params = action.monitoring_query.params

		new_results = platform.fetch_results(params, logger)
		prev_action = action.monitoring_query.monitoring_actions.succeeded.last
		found_new_results = prev_action ? platform.found_new_results?(prev_action.results, new_results) : true

		action.update!(:state => MonitoringAction::State::SUCCEEDED, :results => new_results, :found_new_results => found_new_results)
		logger.info "ENDED_MONITORING_ACTION_JOB: #{action_id}"
	rescue => e
		logger.info "MONITORING_ACTION_JOB_FAILED: #{action_id} : #{e.class} : #{e.message} : #{e.backtrace}"
		action.mark_state(MonitoringAction::State::FAILED)

		# self healing
		# fault tolerant
	end
end
