
class TicketAssignmentService
  def initialize(ticket)
    @ticket = ticket
  end

  def call
    puts "🎫 Ticket assignment service initiated"
    return unless @ticket

    puts "🔍 Trying to assign agent to ticket #{@ticket.id}"

    agent = find_available_agent

    if agent
      @ticket.update!(assigned_to_id: agent.id)
      Rails.logger.info "📧 Sending email to #{agent.firstname} for confirmation"
      TicketMailer.ticket_assigned(@ticket, agent).deliver_now
    else
      Rails.logger.info "⚠️ No available agent found — ticket created without assignment"
    end

    agent
  rescue => e
    Rails.logger.error "❌ Failed to assign ticket: #{e.message}"
    raise
  end

  private

  def find_available_agent
    # Step 1 & 2: Agent with no ACTIVE tickets
    agent = Agent.left_joins(:assigned_tickets)
                 .where("tickets.status = ? OR tickets.id IS NULL", "ACTIVE")
                 .group("agents.id")
                 .having("COUNT(tickets.id) = 0")
                 .first

    # Step 3: Fallback — just pick a random agent
    agent ||= Agent.order(Arel.sql("RANDOM()")).first

    agent
  end
end
