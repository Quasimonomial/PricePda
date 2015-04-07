class PricesMailer < ActionMailer::Base
  default from: "app33882497@heroku.com"

  def prices_report_email user
      @user = user
      @companies = Company.all
      mail(to: @user.email, subject: 'Your price report is ready')
  end
end
