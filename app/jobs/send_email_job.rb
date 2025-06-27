class SendEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id, type)
      # Do something later
      record = type == "agent" ? Agent.find(user_id) : User.find(user_id)
    UserMailer.welcome_email(record).deliver_now
  end
end
