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

  def welcome_email(user)
    @user = user
    puts "this email service was intiated"
    mail(
      to: @user.email,
      subject: "Welcome to our platform!"
    )
  end
end
