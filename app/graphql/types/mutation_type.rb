module Types
  class MutationType < Types::BaseObject
    description "The mutation root of this schema"

    # Authentication mutations
    field :login, mutation: Mutations::Authentication::Login, description: "Login user with email and password"
    field :signup, mutation: Mutations::Authentication::Signup, description: "Create a new user account"
    # Ticket mutations
    field :create_ticket, mutation: Mutations::Tickets::CreateTickets, description: "Create a new ticket"
    field :update_ticket, mutation: Mutations::Tickets::UpdateTickets, description: "Update a new ticket"
    # Comment mutations
    field :create_comment, mutation: Mutations::Comments::CreateComment, description: "create a new comment"
    field :delete_comment, mutation: Mutations::Comments::DeleteComment, description: "delete a new comment"
  end
end
