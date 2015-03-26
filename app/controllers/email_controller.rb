class EmailController < ApplicationController
  before_action :require_logged_in!, except: [:resend_activation_email]
  before_action :require_admin_access!, only: [:send_to_all]

  def send_to_all
    puts 'routed to'
    users = User.all
    users.each do |user|
      PricesMailer.prices_report_email(user).deliver
    end
    render json: {message: "Email Sent!"}.to_json
  end

  def send_to_self
    puts 'routed to'
    PricesMailer.prices_report_email(current_user).deliver
    render json: {message: "Email Sent!"}.to_json
  end

  def resend_activation_email
    @user = User.find_by_email(params[:email])
    if @user
      @user.create_activation_digest
      unless @user.activated
        UserMailer.account_activation(@user).deliver
      end
    end
    redirect_to :root
  end
end