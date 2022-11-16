class ProcessAlertJob
	include Sidekiq::Job

	def perform
		# TODO: redis locks to prevent same job parallel execution
		actions = MonitoringAction.pending_notification
		actions.pluck(:monitoring_query_id).uniq.each { |query_id|
			ALERT_EMAIL_IDS.each { |email|
				AlertMailer.with(:query_id => query_id, :email => email).new_entries_alert.deliver_now #async required?
				# TODO: Store sent alert logs in a table
			}
		}
		actions.update_all(:notified => true)
	rescue => e
		logger.error "PROCESS_ALERT_JOB_FAILED: #{e.class} - #{e.message} - #{e.backtrace}"
		#TODO: stat
		#TODO: Admin alert
	ensure
		ProcessAlertJob.perform_in(1.minutes)
	end
end
