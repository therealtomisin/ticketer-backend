# spec/graphql/mutations/authentication/login_spec.rb
require "rails_helper"

RSpec.describe Mutations::Authentication::Login, type: :request do
  let(:mutation) do
    <<~GQL
      mutation Login($input: LoginInput!) {
        login(input: $input) {
          success
          message
          token
          user {
            email
          }
        }
      }
    GQL
  end

  let!(:user) { User.create!(email: "user@example.com", password: "password", firstname: "User", lastname: "Surname") }

  it "logs in a valid user" do
    post "/graphql", params: {
      query: mutation,
      variables: {
        input: {
          email: "user@example.com",
          password: "password",
          type: "user"
        }
      }
    }

    data = JSON.parse(response.body)["data"]["login"]

    expect(data["success"]).to eq(true)
    expect(data["token"]).not_to be_nil
    expect(data["user"]["email"]).to eq("user@example.com")
  end

  it "fails with wrong password" do
    post "/graphql", params: {
      query: mutation,
      variables: {
        input: {
          email: "user@example.com",
          password: "wrongpass",
          type: "user"
        }
      }
    }

    data = JSON.parse(response.body)["data"]["login"]

    expect(data["success"]).to eq(false)
    expect(data["message"]).to eq("Invalid email or password")
  end
end
