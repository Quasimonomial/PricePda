class SessionsController < ApplicationController
	before_action :demand_not_logged_in, only: [:new]

	def create
		user = User.find_by_credentials(
			params[:user][:email],
			params[:user][:password]
		)

		if user
			if user.activated
				log_in!(user)
				redirect_to root_url
			else
				flash[:errors] = ["Account not activated. Check your email for the activation link."]
				render :new
			end
		else
			flash[:errors] = ["Invalid Credentials"]
			render :new
		end
	end

	def new
		render :new
	end

	def destroy
		log_out!
		redirect_to new_session_url
	end

	private
	def demand_not_logged_in
		redirect_to root_url if logged_in?
	end

	def user_params
		params.require(:user).permit(:email, :password, :price_range_percentage)
	end
end