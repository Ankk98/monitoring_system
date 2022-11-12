class AlertMailer < ApplicationMailer
	def new_entries_alert
		#@user = params[:user]
    #@url  = 'http://example.com/login'
		@platform = "sdvdsv"
		@query_result = "sdvsddsv"
		@new_entries_found = "sdvsdvds"
		# params[:email]
    mail(to: "ankk98@gmail.com", subject: 'Welcome to My Awesome Site')
	end
end
