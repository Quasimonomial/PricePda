class PricesMailer < ActionMailer::Base
  default from: "app33882497@heroku.com"

  def hello_world_email user
      mail(to: user.email, subject: 'hello world from vetpda!')
  end
end
