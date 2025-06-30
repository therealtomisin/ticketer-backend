require 'rails_helper'

RSpec.describe Mutations::Tickets::UpdateTickets, type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password", firstname: "Jane", lastname: "Doe") }
  let(:agent) { Agent.create!(email: "agent@example.com", password: "password", firstname: "Agent", lastname: "Smith", role: "SUPERADMIN") }
  let(:ticket) { Ticket.create!(title: "Testing ticket", content: "Details of the testing script", created_by: user, ticket_key: SecureRandom.hex(8), deadline: 2.days.from_now, status: 'ACTIVE') }

  let(:mutation) do
    <<~GQL
      mutation($id: ID!, $status: String, $hasUserDeleted: Boolean) {
        updateTicket(input: { id: $id, status: $status, hasUserDeleted: $hasUserDeleted }) {
          ticket {
            id
            status
            hasUserDeleted
          }
          message
        }
      }
    GQL
  end

  it "updates status if agent is SUPERADMIN" do
  result = TicketerBackendSchema.execute(
    mutation,
    variables: {
      id: ticket.id,
      status: "RESOLVED",
      hasUserDeleted: false
    },
    context: { current_agent: agent }
  )

  # puts JSON.pretty_generate(result.to_h) # 👈 debug output

  data = result.dig("data", "updateTicket")
  expect(data["ticket"]["status"]).to eq("RESOLVED")
  expect(data["message"]).to eq("Ticket updated successfully")
end


  it "returns error for invalid status" do
    result = TicketerBackendSchema.execute(
      mutation,
      variables: {
        id: ticket.id,
        status: "INVALID_STATUS"
      },
      context: { current_user: user }
    )

    expect(result["errors"].first["message"]).to eq("Invalid status")
  end
end
