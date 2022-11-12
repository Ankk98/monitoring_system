# Preview all emails at http://localhost:3000/rails/mailers/alert_mailer
class AlertMailerPreview < ActionMailer::Preview
	def new_entries_alert
		AlertMailer.new_entries_alert
	end
end
