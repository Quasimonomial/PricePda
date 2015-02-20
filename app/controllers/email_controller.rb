class EmailController < ApplicationController
  before_action :require_logged_in!

  def send_to_all
    puts 'routed to'
    users = User.all
    users.each do |user|
      PricesMailer.prices_report_email(user).deliver
    end
  end

  def send_to_self
    puts 'routed to'
    PricesMailer.prices_report_email(current_user).deliver
  end
end