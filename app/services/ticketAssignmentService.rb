class TicketAssignmentService
  def initialize(ticket)
    @ticket = ticket
  end

  def call
    puts "the ticket email service has been initiated"
    return unless @ticket

    puts "calling the callmethod to assign agent to ticket #{@ticket.ticketKey}"

    # Step 1 & 2: Get an agent without an active ticket in a single query
    agent = Agent.left_joins(:assigned_tickets)
                 .where("tickets.status = ? OR tickets.id IS NULL", "ACTIVE")
                 .group("agents.id")
                 .having("COUNT(tickets.id) = 0")
                 .first

    # Step 3: Fallback to a random agent if all have active tickets
    agent ||= Agent.order(Arel.sql("RANDOM()")).first
    return unless agent

    # Step 4: Assign the ticket
    @ticket.update!(assigned_to_id: agent.id)

    # Step 5: Notify
    Rails.logger.info "Sending email to #{agent.firstname} for confirmation"
    TicketMailer.ticket_assigned(@ticket, agent).deliver_now

    agent
  rescue => e
    Rails.logger.error "Failed to assign ticket: #{e.message}"
    raise
  end
end
