class MasterMonitoringJob
  include Sidekiq::Job

  def perform(*args)
		logger.info "MASTER_MONITORING_JOB_STARTED"
		return
		Platform::KLASSES.each { |id, platform_klass|
			platform_klass.monitor(logger)
			# TODO: check running jobs, check errors, enqueue job
			# redis mutex
		}
		logger.info "MASTER_MONITORING_JOB_ENDED"
	rescue => e
		logger.error "MASTER_MONITOR_JOB_FAILED: #{e.class} - #{e.message} - #{e.backtrace}"
		# Add stat
	ensure
		MasterMonitoringJob.perform_in(1.minutes)
  end
end
