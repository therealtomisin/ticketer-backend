# spec/graphql/mutations/authentication/verify_token_spec.rb
require "rails_helper"

RSpec.describe Mutations::Authentication::VerifyToken, type: :request do
  let(:mutation) do
    <<~GQL
      mutation VerifyToken($input: VerifyTokenInput!) {
        verifyToken(input: $input) {
          success
          message
          user {
            email
          }
        }
      }
    GQL
  end

  it "verifies a valid token and code" do
    user = User.create!(email: "verify@me.com", password: "pass", firstname: "Vine", lastname: "User")
    code = "12345"
    token = JsonWebToken.encode({ code: code, type: "user", id: user.id }, 10.minutes.from_now.to_i)

    post "/graphql", params: {
      query: mutation,
      variables: {
        input: {
          code: code,
          token: token
        }
      }
    }

    data = JSON.parse(response.body)["data"]["verifyToken"]

    expect(data["success"]).to eq(true)
    expect(data["user"]["email"]).to eq("verify@me.com")
  end

  it "fails with wrong code" do
    user = User.create!(email: "wrong@code.com", password: "pass", firstname: "Welc", lastname: "Come")
    token = JsonWebToken.encode({ code: "99999", type: "user", id: user.id }, 10.minutes.from_now.to_i)

    post "/graphql", params: {
      query: mutation,
      variables: {
        input: {
          code: "11111",
          token: token
        }
      }
    }

    data = JSON.parse(response.body)["data"]["verifyToken"]

    expect(data["success"]).to eq(false)
    expect(data["message"]).to eq("Invalid verification code")
  end
end
