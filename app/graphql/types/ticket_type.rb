# # frozen_string_literal: true

# module Types
#   class TicketType < Types::BaseObject
#     field :id, ID, null: false
#     field :title, String, null: false
#     field :content, String, null: false
#     field :created_by_id, Integer, null: false
#     field :assigned_to_id, Integer, null: false
#     field :media, [ String ], null: true
#     field :deadline, GraphQL::Types::ISO8601DateTime
#     field :status, String, null: false
#     field :has_user_deleted, Boolean, null: false
#     field :ticket_key, String, null: false
#     field :created_at, GraphQL::Types::ISO8601DateTime, null: false
#     field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
#   end
# end

# frozen_string_literal: true

module Types
  class TicketType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :content, String, null: false
    field :created_by_id, Integer, null: false
    field :assigned_to_id, Integer, null: false
    field :media, [ String ], null: true
    field :deadline, GraphQL::Types::ISO8601DateTime
    field :status, String, null: false
    field :has_user_deleted, Boolean, null: false
    field :ticket_key, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # ✅ Add this to include comments
    field :comments, [ Types::CommentType ], null: true

    # def comments
    #   # Optional: Filter out deleted comments if needed
    #   # object.comments.where(is_deleted: false)
    # end
  end
end
