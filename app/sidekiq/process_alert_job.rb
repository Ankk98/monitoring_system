class ProcessAlertJob
  include Sidekiq::Job

	def perform
		# TODO: redis locks to prevent same job parallel execution
		actions = MonitoringAction.pending_notification
		actions.pluck(:monitoring_query_id).uniq.each { |query_id|
			ALERT_EMAIL_IDS.each { |email|
				AlertMailer.with(:query_id => query_id, :email => email).new_entries_alert.deliver_now #async required?
				# what if it fails partially?
			}
		}
		actions.update_all(:notified => true)
	end
end
