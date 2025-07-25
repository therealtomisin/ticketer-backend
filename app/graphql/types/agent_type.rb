# frozen_string_literal: true

module Types
  class AgentType < Types::BaseObject
    field :id, ID, null: false
    field :firstname, String
    field :lastname, String
    field :email, String
    field :password_digest, String
    field :role, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
