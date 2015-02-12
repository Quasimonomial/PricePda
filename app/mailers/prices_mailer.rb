class PricesMailer < ActionMailer::Base
  default from: "from@example.com"

  def hello_world_email
    @users = User.all
    puts "sending email"
    @users.each do |user|
      mail(to: user.email, subject: 'hello world from vetpda!')
    end
  end


end
