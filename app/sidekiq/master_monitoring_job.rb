class MasterMonitoringJob
  include Sidekiq::Job

	def get_down_platforms
		#TODO: use redis to get data of pltform failures, avoid enqueing their jobs for few minutes
		[]
	end

  def perform
		logger.info "MASTER_MONITORING_JOB_STARTED"

		down_platforms = get_down_platforms
		pending_actions = MonitoringAction.pending

		MonitoringQuery.valid.each { |query|
			prev_action = query.monitoring_actions.finished.last
			next if prev_action && ((prev_action.updated_at + query.interval) >= Time.current)

			if pending_actions.pluck(:monitoring_query_id).include?(query.id)
				logger.info "PREV_ACTION_STILL_RUNNING: #{query.id}"
				next
			end

			if down_platforms.include?(query.platform_id)
				logger.info "TOO_MANY_FAILURES_ON_PLATFORM: #{query.platform_id} - #{query.id}"
			end

			action = MonitoringAction.create(
				:monitoring_query_id => query.id,
				:state => MonitoringAction::State::INITIALIZED
			)
			MonitoringActionJob.perform_async(action.id)
		}
		logger.info "MASTER_MONITORING_JOB_ENDED"
	rescue => e
		logger.error "MASTER_MONITOR_JOB_FAILED: #{e.class} - #{e.message} - #{e.backtrace}"
		# Add stat
		# Not raising error as not confident how sidekiq handles it
	ensure
		MasterMonitoringJob.perform_in(1.minutes)
		# Use scheduler
  end
end
