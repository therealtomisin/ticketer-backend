class UserMailer < ApplicationMailer
  default from: ENV["SENDER_EMAIL"]

  def account_verification(user)
    @user = user
    @verification_url = "#{Rails.application.config.frontend_url}/verify-account?token=#{@user.verification_token}"

    mail(
      to: @user.email,
      subject: "Please verify your account"
    )
  end

  def password_reset(user)
    @user = user
    @reset_url = "#{Rails.application.config.frontend_url}/reset-password?token=#{@user.password_reset_token}"

    mail(
      to: @user.email,
      subject: "Password reset instructions"
    )
  end

  def password_changed(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Your password has been changed"
    )
  end

def welcome_email(account, verification_code)
  @account = account
  @verification_code = verification_code
  puts "Sending welcome email to #{@account.firstname} with code #{@verification_code}"
  mail(to: @account.email, subject: "Welcome! Your verification code")
end
end
