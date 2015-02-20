class SessionsController < ApplicationController
	def create
		user = User.find_by_credentials(
			params[:user][:email],
			params[:user][:password]
		)

		if user
		  # PricesMailer.hello_world_email.deliver
			log_in!(user)
			redirect_to root_url
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
	def user_params
		params.require(:user).permit(:email, :password, :price_range_percentage)
	end
end