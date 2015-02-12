class PricesMailer < ActionMailer::Base
  default from: "app33882497@heroku.com"

  def hello_world_email
    @users = User.all
    puts "sending email"
    @users.each do |user|
      mail(to: user.email, subject: 'hello world from vetpda!')
    end
  end
  # config.action_mailer.default_url_options = { :host => 'heroku.com' }


end
