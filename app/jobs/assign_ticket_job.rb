class AssignTicketJob < ApplicationJob
  queue_as :default

  def perform(ticket_id)
    # Find the ticket to be assigned
    ticket = Ticket.find_by(id: ticket_id)
    return unless ticket

    # Step 1: Get all active tickets with assigned agents
    active_assigned_agent_ids = Ticket.where(status: "ACTIVE")
                                      .where.not(assigned_to_id: nil)
                                      .pluck(:assigned_to_id)
                                      .uniq

    # Step 2: Find agents with no active ticket assigned
    agent_without_active_ticket = Agent.where.not(id: active_assigned_agent_ids).first

    # Step 3: Choose an agent — either one without active tickets, or a random one
    agent = agent_without_active_ticket || Agent.order("RANDOM()").first

    return unless agent

    # Step 4: Assign the ticket
    ticket.update(assigned_to_id: agent.id)

    puts "sending email to #{agent.firstname} for confirmation"

    TicketMailer.ticket_assigned(ticket, agent).deliver_now

    # Step 5: Output confirmation
    puts "The ticket with the id #{ticket.id} has been assigned to you #{agent.id}"
  end
end
