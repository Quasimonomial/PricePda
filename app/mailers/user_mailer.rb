class UserMailer < ActionMailer::Base
  default from: "app33882497@heroku.com"


  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end

end