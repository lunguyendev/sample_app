class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    @greeting = t "email.activation_acc.greeting"
    mail to: @user.email, subject: t("email.activation_acc.greeting")
  end

  def password_reset
    @greeting = "Hi"
    mail to: "to@example.org"
  end
end
