class PricesMailer < ActionMailer::Base
  default from: "app33882497@heroku.com"

  def hello_world_email user
      mail(to: user.email, subject: 'hello world from vetpda!')
  end

    def prices_report_email user
      @user = user
      mail(to: @user.email, subject: 'Your price report is ready')
  end
end
