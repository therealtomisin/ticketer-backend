class TicketNotifierJob < ApplicationJob
  queue_as :default

  def perform
    Agent.find_each do |agent|
      active_ticket_ids = agent.assigned_tickets.where(status: "ACTIVE").pluck(:id)

      if active_ticket_ids.any?
        TicketMailer.outstanding_tickets_reminder(agent.id, active_ticket_ids).deliver_now
      end
    end
  end
end
