class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    @greeting = t "email.activation_acc.greeting"
    mail to: @user.email, subject: t("email.activation_acc.subject")
  end

  def password_reset user
    @user = user
    @greeting = t "email.password.greeting"
    mail to: @user.email, subject: t("email.password.subject")
  end
end
