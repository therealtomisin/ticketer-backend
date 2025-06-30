module Mutations
  module Authentication
class Signup < BaseMutation
  argument :email, String, required: true
  argument :password, String, required: true
  argument :firstname, String, required: true
  argument :lastname, String, required: true
  argument :type, String, required: true # "user" or "agent"
  argument :role, String, required: false # Only for agents

  # field :user, Types::UserType, null: true
  # field :agent, Types::AgentType, null: true
  field :token, String, null: true
  field :success, Boolean, null: false
  field :message, String, null: true
  field :expires_in, Integer, null: true

def resolve(email:, password:, firstname:, lastname:, type:, role: nil)
  puts "the first name >>> #{firstname} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  begin
    unless %w[user agent].include?(type.downcase)
      return {
        success: false,
        message: "Invalid user type. Must be 'user' or 'agent'"
      }
    end

    model = type.downcase == "user" ? User : Agent

    if model.exists?(email: email.downcase.strip)
      return {
        success: false,
        message: "#{type.capitalize} with this email already exists"
      }
    end

    account = case type.downcase
    when "user"
                User.new(
                  email: email.downcase.strip,
                  password: password,
                  firstname: firstname.strip,
                  lastname: lastname.strip
                )
    when "agent"
                Agent.new(
                  email: email.downcase.strip,
                  password: password,
                  firstname: firstname.strip,
                  lastname: lastname.strip,
                  role: role.presence || "ADMIN"
                )
    end

    if account.save
      # Generate a random 5-digit numeric code
      verification_code = rand(10000..99999).to_s

      # Encode the code with JWT (you can include an expiration if needed)
      token = JsonWebToken.encode({ code: verification_code, type: type, id: account.id }, 30.minutes.from_now.to_i)
puts "got here about to send mail #{account.firstname} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      # Send raw code via welcome email
      UserMailer.welcome_email(account, verification_code).deliver_now

      {
        token: token,
        user: type == "agent" ? nil : account,
        agent: type == "user" ? nil : account,
        success: true,
        message: "Account created successfully",
        expires_in: 30.minutes.from_now.to_i
      }
    else
      {
        # user: nil,
        token: nil,
        success: false,
        message: account.errors.full_messages.join(", "),
        expires_in: nil
      }
    end
  rescue => e
    {
      success: false,
      message: "Signup failed: #{e.message}"
    }
  end
end
end

class Login < BaseMutation
        argument :email, String, required: true
        argument :password, String, required: true
        argument :type, String, required: true # "user" or "agent"

        field :user, Types::UserType, null: true
        field :agent, Types::AgentType, null: true
        field :token, String, null: true
        field :success, Boolean, null: false
        field :message, String, null: true
        field :expires_in, Integer, null: true

  def resolve(email:, password:, type:)
  klass = case type.downcase
  when "user" then User
  when "agent" then Agent
  else
            raise GraphQL::ExecutionError, "Invalid type provided: must be 'user' or 'agent'"
  end

  account = klass.find_by(email: email.downcase.strip)

  puts "👤 Type: #{type}, Lookup: #{klass}, Found: #{account&.email}"

  if account&.authenticate(password)
    unless account.isVerified
      verification_code = rand(10000..99999).to_s

      token = JsonWebToken.encode({
        code: verification_code,
        type: type,
        id: account.id
      }, 30.minutes.from_now.to_i)

      puts "📨 Sending verification email to #{account.email} >>>>>>>>>>>>>>>>>>>>>>>>>>"

      UserMailer.welcome_email(account, verification_code).deliver_now

      return {
        success: false,
        message: "Account not verified. Verification code sent to email.",
        token: token,
        expires_in: 30.minutes.to_i,
        user: nil,
        agent: nil
      }
    end

    token = JsonWebToken.encode({
      id: account.id,
      type: type.upcase,
      **(account.is_a?(Agent) ? { role: account.role } : {})
    })

    puts "✅ Authenticated #{type}: #{account.inspect}"

    {
      user: type == "user" ? account : nil,
      agent: type == "agent" ? account : nil,
      token: token,
      success: true,
      message: "Login successful",
      expires_in: 24.hours.to_i
    }
  else
    puts "❌ Invalid login for #{type} with email: #{email}"
    {
      success: false,
      message: "Invalid email or password",
      token: nil,
      expires_in: nil,
      user: nil,
      agent: nil
    }
  end
  rescue StandardError => e
  puts "🔥 Exception during login: #{e.message}"
  {
    success: false,
    message: "Login failed: #{e.message}",
    token: nil,
    expires_in: nil,
    user: nil,
    agent: nil
  }
  end


  # def resolve(email:, password:, type:)
  #   klass = case type.downcase
  #   when "user" then User
  #   when "agent" then Agent
  #   else
  #             raise GraphQL::ExecutionError, "Invalid type provided: must be 'user' or 'agent'"
  #   end

  #   user_or_agent = klass.find_by(email: email.downcase.strip)

  #   puts "👤 Type: #{type}, Lookup: #{klass}, Found: #{user_or_agent&.email}"

  #   if user_or_agent&.authenticate(password)

  #     puts "the user is >>> #{user_or_agent} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

  #     token = JsonWebToken.encode({
  #       id: user_or_agent.id,
  #       type: type.upcase, # e.g., "USER" or "AGENT",
  #       **(user_or_agent.is_a?(Agent) ? { role: user_or_agent.role } : {})
  #     })

  #     puts "✅ Authenticated #{type}: #{user_or_agent.inspect}"

  #     {
  #       user: type == "user" ? user_or_agent : nil,
  #       agent: type == "agent" ? user_or_agent : nil,
  #       token: token,
  #       success: true,
  #       message: "Login successful",
  #       expires_in: 24.hours.to_i
  #     }
  #   else
  #     puts "❌ Invalid login for #{type} with email: #{email}"
  #     {
  #       success: false,
  #       message: "Invalid email or password"
  #     }
  #   end
  # rescue StandardError => e
  #   puts "🔥 Exception during login: #{e.message}"
  #   {
  #     success: false,
  #     message: "Login failed: #{e.message}"
  #   }
  # end
end

      class VerifyToken < BaseMutation
      argument :code, String, required: true
      argument :token, String, required: true

      field :user, Types::UserType, null: true
      field :agent, Types::AgentType, null: true
      field :success, Boolean, null: false
      field :message, String, null: true

      def resolve(code:, token:)
        begin
          decoded = JsonWebToken.decode(token)

          # Ensure token contains code and type
          actual_code = decoded["code"]
          user_type = decoded["type"]&.downcase

          unless actual_code && user_type
            raise GraphQL::ExecutionError, "Invalid token structure"
          end

          if code.strip != actual_code.strip
            return {
              success: false,
              message: "Invalid verification code",
              user: nil,
              agent: nil
            }
          end

          # Lookup the user/agent based on type and return them
          klass = case user_type
          when "user" then User
          when "agent" then Agent
          else
                    raise GraphQL::ExecutionError, "Unknown user type: #{user_type}"
          end

          # Optionally, you could embed `email` or `id` in the token to find them directly
          user_or_agent = klass.find_by(id: decoded["id"])

          unless user_or_agent
            return {
              success: false,
              message: "#{user_type.capitalize} not found",
              user: nil,
              agent: nil
            }
          end

          {
            success: true,
            message: "Verification successful",
            user: user_type == "user" ? user_or_agent : nil,
            agent: user_type == "agent" ? user_or_agent : nil
          }

        rescue JWT::DecodeError
          {
            success: false,
            message: "Invalid token",
            user: nil,
            agent: nil
          }
        rescue => e
          {
            success: false,
            message: "Verification failed: #{e.message}",
            user: nil,
            agent: nil
          }
        end
      end
      end
  end
end
