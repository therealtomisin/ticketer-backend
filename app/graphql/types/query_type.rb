# # frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    ### --- Users ---
    field :users, [ Types::UserType ], null: false
    def users
      User.all
    end

    field :user, Types::UserType, null: false do
      argument :id, ID, required: true
    end
    def user(id:)
      User.find(id)
    end

    ### --- Agents ---
    field :agents, [ Types::AgentType ], null: false
    def agents
      Agent.all
    end

    field :agent, Types::AgentType, null: false do
      argument :id, ID, required: true
    end
    def agent(id:)
      Agent.find(id)
    end

    field :tickets, [ Types::TicketType ], null: false

    def tickets
      Ticket.all
    end

### --- Tickets ---
field :tickets_by_user, [ Types::TicketType ], null: false do
  argument :status, String, required: false
  argument :has_user_deleted, Boolean, required: false
  # argument :user_id, ID, required: false
  # argument :agent_id, ID, required: false
  argument :from, GraphQL::Types::ISO8601DateTime, required: false
  argument :to, GraphQL::Types::ISO8601DateTime, required: false
end
def tickets_by_user(status: nil, has_user_deleted: nil, user_id: nil, agent_id: nil, from: nil, to: nil)
  scope = Ticket.all

    current_user = context[:current_agent] || context[:current_user]

  # puts "the current user >>> #{current_user}"

  if current_user
    if current_user.respond_to?(:role) && current_user.role.present?
      agent_id ||= current_user.id
    else
      user_id ||= current_user.id
    end
  end

puts "agent id #{agent_id} user id #{user_id}"

  scope = scope.where(status: status) if status.present?
  scope = scope.where(has_user_deleted: has_user_deleted) unless has_user_deleted.nil?
  scope = scope.where(created_by_id: user_id) if user_id.present?
  scope = scope.where(assigned_to_id: agent_id) if agent_id.present?
  scope = scope.where("created_at >= ?", from) if from.present?
  scope = scope.where("created_at <= ?", to) if to.present?
  scope
end

    field :ticket, Types::TicketType, null: false do
      argument :id, ID, required: true
    end
    def ticket(id:)
      Ticket.find(id)
    end

    ### --- Comments ---
    field :comments, [ Types::CommentType ], null: false do
      argument :ticket_id, ID, required: false
      argument :created_by_type, String, required: false
      argument :is_deleted, Boolean, required: false
    end
    def comments(ticket_id: nil, created_by_type: nil, is_deleted: false)
      scope = Comment.all
      scope = scope.where(ticket_id: ticket_id) if ticket_id.present?
      scope = scope.where(created_by_type: created_by_type) if created_by_type.present?
      scope = scope.where(is_deleted: is_deleted) unless is_deleted.nil?
      scope
    end

    field :comment, Types::CommentType, null: false do
      argument :id, ID, required: true
    end
    def comment(id:)
      Comment.find(id)
    end
  end
end
