# spec/graphql/mutations/authentication/signup_spec.rb
require 'rails_helper'

RSpec.describe Mutations::Authentication::Signup, type: :request do
  let(:mutation) do
    <<~GQL
      mutation Signup($input: SignupInput!) {
        signup(input: $input) {
          success
          message
          token
          expiresIn
        }
      }
    GQL
  end

  context "when creating a user" do
    it "successfully signs up a user" do
      post "/graphql", params: {
        query: mutation,
        variables: {
          input: {
            email: "user@example.com",
            password: "securepass",
            firstname: "John",
            lastname: "Doe",
            type: "user"
          }
        }
      }

      json = JSON.parse(response.body)
      data = json["data"]["signup"]

      expect(data["success"]).to eq(true)
      expect(data["token"]).not_to be_nil
      expect(User.find_by(email: "user@example.com")).to be_present
    end

    it "fails with duplicate email" do
      User.create!(email: "dupe@example.com", password: "secret", firstname: "Duper", lastname: "Epper")

      post "/graphql", params: {
        query: mutation,
        variables: {
          input: {
            email: "dupe@example.com",
            password: "newpass",
            firstname: "New",
            lastname: "User",
            type: "user"
          }
        }
      }

      json = JSON.parse(response.body)
      data = json["data"]["signup"]

      expect(data["success"]).to eq(false)
      expect(data["message"]).to include("already exists")
    end
  end

  context "when creating an agent" do
    it "creates an agent with a default role" do
      post "/graphql", params: {
        query: mutation,
        variables: {
          input: {
            email: "agent@company.com",
            password: "adminpass",
            firstname: "Jane",
            lastname: "Smith",
            type: "agent"
          }
        }
      }

      data = JSON.parse(response.body)["data"]["signup"]

      expect(data["success"]).to eq(true)
      agent = Agent.find_by(email: "agent@company.com")
      expect(agent).to be_present
      expect(agent.role).to eq("ADMIN")
    end
  end
end
