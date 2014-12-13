class SessionsController < ApplicationController
	def create
		user = User.find_by_credentials(
			params[:user][:username],
			params[:user][:password]
		)

		if user
			log_in(user)
			redirect_to root_url
		else
			flash[:errors] = ["Invalid Credentials"]
		end
	end

	def new
		render :new
	end

	def delete
		log_out!
		redirect_to new_session_url
	end
end