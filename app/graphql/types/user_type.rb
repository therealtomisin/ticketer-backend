# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :firstname, String
    field :lastname, String
    field :email, String
    field :password_digest, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tickets, [ Types::TicketType ], null: false
    #     field :unassigned_tickets_count, Integer, null: false

    # def unassigned_tickets_count
    #   object.tickets.where(assigned_to_id: nil).count
    # end
  end
end
