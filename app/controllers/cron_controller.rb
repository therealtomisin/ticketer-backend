# app/controllers/cron_controller.rb
class CronController < ApplicationController
  # Optional: Add basic auth or header token for security

  def notify_agents
    # CleanupJob.perform_later
    TicketNotifierJob.perform_now
    render json: { message: "Cleanup triggered" }, status: :ok
  end
end
