require 'rails_helper'

RSpec.describe Mutations::Comments::CreateComment, type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password", firstname: "Jane", lastname: "Doe") }
  let(:agent) { Agent.create!(email: "agent@example.com", password: "password", firstname: "Agent", lastname: "Smith", role: "ADMIN") }

  let(:ticket) do
    Ticket.create!(
      title: "User ticket ooo",
      content: "Needs help for something",
      created_by: user,
      assigned_to: agent,
      ticket_key: SecureRandom.hex(8),
      deadline: 3.days.from_now
    )
  end

  let!(:agent_comment) do
    Comment.create!(content: "Agent has responded", ticket: ticket, created_by: agent)
  end

  let(:mutation) do
    <<~GQL
      mutation($ticketId: ID!, $content: String!) {
        createComment(input: { ticketId: $ticketId, content: $content }) {
          comment {
            id
            content
          }
          message
        }
      }
    GQL
  end

  it "allows user to comment after agent has commented" do
    result = TicketerBackendSchema.execute(
      mutation,
      variables: {
        ticketId: ticket.id,
        content: "Thanks for the update"
      },
      context: { current_user: user }
    )

    data = result.dig("data", "createComment")
    expect(data["comment"]["content"]).to eq("Thanks for the update")
    expect(data["message"]).to eq("Comment created successfully")
  end

  it "disallows user from commenting before agent responds" do
    # Clear agent comment
    Comment.delete_all

    result = TicketerBackendSchema.execute(
      mutation,
      variables: {
        ticketId: ticket.id,
        content: "Any update?"
      },
      context: { current_user: user }
    )

    expect(result["errors"][0]["message"]).to eq("You can only comment after an agent has responded")
  end

  it "allows agent to comment anytime" do
    result = TicketerBackendSchema.execute(
      mutation,
      variables: {
        ticketId: ticket.id,
        content: "We are looking into it"
      },
      context: { current_user: agent }
    )

    data = result.dig("data", "createComment")
    expect(data["comment"]["content"]).to eq("We are looking into it")
  end

  # it "returns error for deleted ticket status" do
  #   ticket.update(status: "DELETED")

  #   result = TicketerBackendSchema.execute(
  #     mutation,
  #     variables: {
  #       ticketId: ticket.id,
  #       content: "Cannot comment"
  #     },
  #     context: { current_user: agent }
  #   )

  #   expect(result["errors"][0]["message"]).to match(/Cannot comment on a ticket with status/i)
  # end

  it "returns error if user is unauthorized" do
    stranger = User.create!(email: "stranger@example.com", password: "password", firstname: "ThisNiggaName", lastname: "IsNotImportant")

    result = TicketerBackendSchema.execute(
      mutation,
      variables: {
        ticketId: ticket.id,
        content: "I'm not allowed"
      },
      context: { current_user: stranger }
    )

    expect(result["errors"][0]["message"]).to eq("You are not authorized to comment on this ticket")
  end
end
