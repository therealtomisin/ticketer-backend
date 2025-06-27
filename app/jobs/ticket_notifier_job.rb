class TicketNotifierJob < ApplicationJob
  queue_as :default

  def perform
    Agent.find_each do |agent|
      active_tickets = agent.tickets.where(status: "ACTIVE")

      if active_tickets.exists?
        TicketMailer.outstanding_tickets_reminder(agent, active_tickets).deliver_later
      end
    end
  end
end
