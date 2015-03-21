class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.valid_activation?(params[:id])
      user.update_attribute(:activated,    true)
      log_in! user
      puts "success me maybe"
      flash[:success] = "Account activated!"
      redirect_to root_url
    else
      flash[:danger] = "Invalid activation link"
      puts "Fail me baby"
      redirect_to root_url
    end
  end
end