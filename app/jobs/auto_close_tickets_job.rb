class AutoCloseTicketsJob < ApplicationJob
  queue_as :default

  def perform
    Ticket.where(status: "OPEN").where("deadline < ?", Time.current).find_each do |ticket|
      ticket.update(status: "ESCALATED") # or 'closed', depending on your status list
      # Optional: Notify the user
      TicketMailer.ticket_auto_closed(ticket).deliver_later
    end
  end
end
