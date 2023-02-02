class MasterMonitoringJob
	include Sidekiq::Job

	def get_down_platforms
		time = Time.current
		Platform::TYPES.select { |type|
			curr_interval = Platform::get_time_interval(time)
			curr_failed_count = Platform.get_platform_failed_count(type, time)

			prev_interval = Platform::get_time_interval(time - Platform::INTERVAL_SIZE)
			prev_failed_count = Platform.get_platform_failed_count(type, time - Platform::INTERVAL_SIZE)

			(curr_failed_count + prev_failed_count) > Platform::FAIL_THRESHOLD
		}
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
		# TODO: Add stat
		# TODO: Not raising error as not confident how sidekiq handles it
	ensure
		MasterMonitoringJob.perform_in(1.minutes)
		# TODO: Use scheduler
	end
end
