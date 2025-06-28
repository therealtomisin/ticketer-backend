class TicketAssignmentService
  def initialize(ticket)
    @ticket = ticket
  end

  def call
    puts "the ticket email service has been initiated"
    return unless @ticket

    puts "calling the callmethod to assign agent to ticket #{@ticket.id}"

    # Step 1 & 2: Get an agent without an active ticket in a single query
    agent = Agent.left_joins(:assigned_tickets)
                 .where("tickets.status = ? OR tickets.id IS NULL", "ACTIVE")
                 .group("agents.id")
                 .having("COUNT(tickets.id) = 0")
                 .first

    puts "found agent #{agent.email}"

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

# class TicketAssignmentService
#   def initialize(ticket)
#     @ticket = ticket
#   end

#   def call
#     return unless @ticket

#     # Step 1: Get all active tickets with assigned agents
#     active_assigned_agent_ids = Ticket.where(status: "ACTIVE")
#                                       .where.not(assigned_to_id: nil)
#                                       .pluck(:assigned_to_id)
#                                       .uniq

#     # Step 2: Find agents with no active ticket assigned
#     agent_without_active_ticket = Agent.where.not(id: active_assigned_agent_ids).first

#     # Step 3: Choose an agent
#     agent = agent_without_active_ticket || Agent.order("RANDOM()").first

#     return unless agent

#     # Step 4: Assign the ticket
#     @ticket.update!(assigned_to_id: agent.id)

#     # Step 5: Send email
#     Rails.logger.info "Sending email to #{agent.firstname} for confirmation"
#     TicketMailer.ticket_assigned(@ticket, agent).deliver_now

#     # Return the agent for any additional processing
#     agent
#   rescue => e
#     Rails.logger.error "Failed to assign ticket: #{e.message}"
#     raise # Re-raise if you want the mutation to fail
#   end
# end
