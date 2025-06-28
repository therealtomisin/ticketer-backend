class TicketMailer < ApplicationMailer
  default from: "oluwatimilehineribake@gmail.com"

  def ticket_created(ticket)
    @ticket = ticket
    @user = ticket.user
    mail(to: @user.email, subject: "Your Ticket ##{ticket.ticket_key} Has Been Created")
  end

  def ticket_updated(ticket)
    @ticket = ticket
    @user = ticket.user
    mail(to: @user.email, subject: "Your Ticket ##{ticket.ticket_key} Has Been Updated")
  end

  # def comment_added(ticket, comment)
  #   @ticket = ticket
  #   @comment = comment
  #   @user = ticket.user
  #   mail(to: @user.email, subject: "A New Comment on Your Ticket ##{ticket.ticket_key}")
  # end
  #
  def comment_notification(recipient, ticket, comment)
    @recipient = recipient
    @ticket = ticket
    @comment = comment

    # Dynamic subject
    subject_line =
      if recipient.is_a?(Agent)
        "A user responded to ticket ##{ticket.id}"
      else
        "An agent responded to your ticket ##{ticket.id}"
      end

    mail(to: recipient.email, subject: subject_line)
  end


  def ticket_assigned(ticket, agent)
    puts "why not >> #{agent.firstname}"
    @ticket = ticket
    @agent = agent
    return unless @agent&.email.present?

    mail(to: @agent.email, subject: "You’ve Been Assigned to Ticket ##{ticket.ticket_key}")
  end

  def outstanding_tickets_reminder(agent, tickets)
    @agent = agent
    @tickets = tickets
    mail(to: agent.email, subject: "Daily ticket report! ✅")
  end

  def ticket_auto_closed(ticket)
    @ticket = ticket
    @agent = ticket.assigned_to
    mail(to: @agent.email, subject: "Your ticket ##{ticket.id} has been escalated")
  end
end
