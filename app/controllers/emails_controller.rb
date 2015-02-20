class EmailsController < ApplicationController
  before_action :require_logged_in!

  def send_to_all
    puts 'routed to'
    users = User.all
    users.each do |user|
      PricesMailer.hello_world_email(user).deliver
    end
  end

  def send_to_self
    puts 'routed to'
    PricesMailer.hello_world_email(current_user).deliver
  end
end