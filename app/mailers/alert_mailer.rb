class AlertMailer < ApplicationMailer
	def new_entries_alert
		@query_result = MonitoringQuery.find(params[:query_id])
    mail(to: params[:email], subject: 'New results discovered')
	end
end
