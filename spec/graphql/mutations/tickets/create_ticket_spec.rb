# spec/graphql/mutations/tickets/create_ticket_spec.rb
require "rails_helper"

RSpec.describe Mutations::Tickets::CreateTickets, type: :request do
  describe ".resolve" do
    let(:user) do
      User.create!(
        email: "user@example.com",
        password: "password",
        firstname: "John",
        lastname: "Doe"
      )
    end

    let!(:agent) do
      Agent.create!(
        email: "agent@example.com",
        password: "password",
        firstname: "Agent",
        lastname: "Smith",
        role: 'ADMIN'
      )
    end

    it "creates a ticket with valid input" do
      mutation = <<~GQL
        mutation {
          createTicket(input: {
            title: "Issue with app",
            content: "App crashes on load",
            media: ["https://example.com/image.png"]
          }) {
            ticket {
              id
              title
              content
              media
              ticketKey
            }
            errors
          }
        }
      GQL

      result = TicketerBackendSchema.execute(
        mutation,
        context: { current_user: user }
      )

      puts result.to_h if result["errors"]

      expect(result["errors"]).to be_nil

      ticket_data = result.dig("data", "createTicket", "ticket")
      errors = result.dig("data", "createTicket", "errors")

      expect(errors).to eq([])
      expect(ticket_data["title"]).to eq("Issue with app")
      expect(ticket_data["content"]).to eq("App crashes on load")
      expect(ticket_data["media"]).to include("https://example.com/image.png")
      expect(ticket_data["ticketKey"]).to be_present
    end
  end
end
