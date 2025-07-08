module Mutations
  module Comments
class CreateComment < BaseMutation
  argument :ticket_id, ID, required: true
  argument :content, String, required: true

  field :comment, Types::CommentType, null: true
  field :message, String, null: false

def resolve(ticket_id:, content:)
  user = authenticated_user!
  ticket = Ticket.find_by(id: ticket_id)
  raise GraphQL::ExecutionError, "Ticket not found" unless ticket

  if Ticket::DELETED_STATUSES.include?(ticket.status)
    raise GraphQL::ExecutionError, "Cannot comment on a ticket with status #{ticket.status}"
  end

  # Authorization check: only ticket creator or assigned agent can comment
  unless (user.is_a?(User) && ticket.created_by_id == user.id) ||
         (user.is_a?(Agent) && ticket.assigned_to_id == user.id)
    raise GraphQL::ExecutionError, "You are not authorized to comment on this ticket"
  end

  # Business rule: User cannot comment unless an agent has commented
  if user.is_a?(User)
    agent_has_commented = ticket.comments.where(created_by_type: "Agent").exists?
    unless agent_has_commented
      raise GraphQL::ExecutionError, "You can only comment after an agent has responded"
    end
  end

  comment = Comment.new(
    content: content,
    created_by: user,
    ticket: ticket
  )

  if comment.save
    # Notify the other party
    recipient =
      if user.is_a?(Agent)
        ticket.created_by
      else
        ticket.assigned_to
      end

    TicketMailer.comment_notification(recipient, ticket, comment).deliver_now if recipient

    {
      comment: comment,
      message: "Comment created successfully"
    }
  else
    raise GraphQL::ExecutionError, comment.errors.full_messages.join(", ")
  end
end
end


class DeleteComment < BaseMutation
      argument :id, ID, required: true

      field :comment, Types::CommentType, null: true
      field :message, String, null: false

      def resolve(id:)
        user = authenticated_user!

        comment = Comment.find_by(id: id)
        raise GraphQL::ExecutionError, "Comment not found" unless comment

        if comment.created_by != user
          raise GraphQL::ExecutionError, "You are not authorized to delete this comment"
        end

        if comment.soft_delete!
          {
            comment: comment,
            message: "Comment deleted successfully"
          }
        else
          raise GraphQL::ExecutionError, "Failed to delete comment"
        end
      end
end
  end
end
