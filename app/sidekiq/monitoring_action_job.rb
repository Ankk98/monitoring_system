class MonitoringActionJob
  include Sidekiq::Job

  def perform(action_id)
    logger.info "STARTED_MONITORING_ACTION_JOB: #{action_id}"
		action = MonitoringAction.find(action_id)
		action.mark_state(MonitoringAction::State::RUNNING)
		action.monitoring_query.platform.new.monitor(action, logger)
    logger.info "ENDED_MONITORING_ACTION_JOB: #{action_id}"
	rescue => e
    logger.info "MONITORING_ACTION_JOB_FAILED: #{action_id} : #{e.class} : #{e.message} : #{e.backtrace}"
  	
		# self healing
		# fault tolerant
	end
end
