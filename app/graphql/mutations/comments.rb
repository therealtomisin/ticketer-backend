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

    # Prevent user comment if no agent has commented yet
    if user.is_a?(User)
      agent_comment_exists = ticket.comments.where(created_by_type: "Agent").exists?
      unless agent_comment_exists
        raise GraphQL::ExecutionError, "You can only comment after an agent has responded"
      end
    end

    comment = Comment.new(
      content: content,
      created_by: user,
      ticket: ticket
    )

    if comment.save
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
