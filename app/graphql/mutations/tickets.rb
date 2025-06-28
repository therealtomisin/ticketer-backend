module Mutations
  module Tickets
    class CreateTickets < BaseMutation
    argument :title, String, required: true
    argument :content, String, required: true
    argument :media, [ String ], required: false

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    def resolve(title:, content:, media: [])
      creator = context[:current_user]

      return { ticket: nil, errors: [ "Authentication required" ] } unless creator

      ticket_key = SecureRandom.hex(16).upcase

      deadline = 2.days.from_now

      ticket = Ticket.new(
        title: title,
        content: content,
        media: media,
        ticket_key: ticket_key,
        deadline: deadline,
        created_by: creator
      )



      if ticket.save
        # cannot set this up becuase i am on renders free tier
        # AssignTicketJob.perform_later(ticket.id)
        #
        puts "assigning tticket to an agent"
        TicketAssignmentService.new(ticket).call
        { ticket: ticket, errors: [] }
      else
        { ticket: nil, errors: ticket.errors.full_messages }
      end
    end
    end

    class UpdateTickets < BaseMutation
      VALID_STATUSES = %w[ACTIVE ESCALATED RESOLVED INACTIVE CLOSED]


      argument :id, ID, required: true
      argument :status, String, required: false
      argument :has_user_deleted, Boolean, required: false
      argument :deadline, GraphQL::Types::ISO8601DateTime, required: false

      field :ticket, Types::TicketType, null: true
      field :message, String, null: false

  def resolve(id:, status: nil, has_user_deleted: nil, deadline: nil)
    ticket = Ticket.find_by(id: id)
    raise GraphQL::ExecutionError, "Ticket not found" unless ticket

    user = context[:current_user]
    agent = context[:current_agent]

    if status.present?
      unless VALID_STATUSES.include?(status)
        raise GraphQL::ExecutionError, "Invalid status"
      end

      unless can_change_status?(status, user, agent)
        raise GraphQL::ExecutionError, "You do not have permission to set status to #{status}"
      end

      ticket.status = status
    end

    ticket.has_user_deleted = has_user_deleted unless has_user_deleted.nil?
    ticket.deadline = deadline if deadline.present?

    if ticket.save
      {
        ticket: ticket,
        message: "Ticket updated successfully"
      }
    else
      raise GraphQL::ExecutionError, ticket.errors.full_messages.join(", ")
    end
  end

      private

        def can_change_status?(status, user, agent)
        return status == "INACTIVE" if user
        return status == "RESOLVED" if agent&.role == "ADMIN"
        return true if agent&.role == "SUPERADMIN"
        false
        end
    end
  end
end
