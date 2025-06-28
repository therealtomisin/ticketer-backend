module Mutations
  module Authentication
class Signup < BaseMutation
  argument :email, String, required: true
  argument :password, String, required: true
  argument :firstname, String, required: true
  argument :lastname, String, required: true
  argument :type, String, required: true # "user" or "agent"
  argument :role, String, required: false # Only for agents

  field :user, Types::UserType, null: true
  field :agent, Types::AgentType, null: true
  field :token, String, null: true
  field :success, Boolean, null: false
  field :message, String, null: true
  field :expires_in, Integer, null: true

  def resolve(email:, password:, firstname:, lastname:, type:, role: nil)
    # Validate type
    unless %w[user agent].include?(type.downcase)
       {
        success: false,
        message: "Invalid user type. Must be 'user' or 'agent'"
      }
    end

  puts "active here"

  model = type.downcase == "user" ? User : Agent

if model.exists?(email: email.downcase.strip)
   { success: false,
    message: "#{type.capitalize} with this email already exists"
  }
end

    # Create the appropriate model based on type
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


    puts "<<<<<<<<<<<<<<<<<<<<<<<<<<,the saved account is #{account.email}"

        if account.save
          token = JsonWebToken.encode({
            id: account.id,
            type: type.upcase, # e.g., "USER" or "AGENT",
            **(account.is_a?(Agent) ? { role: account.role } : {})
          })

          UserMailer.welcome_email(account).deliver_now

          puts "the thoen >> #{token}"
          {
            token: token,
            user: type == "agent"? nil : account,
            agent: type == "user"? nil : account,
            success: true,
            message: "Account created successfully",
            expires_in: 24.hours.to_i
          }
        else
          {
            user: nil,
            token: nil,
            success: false,
            message: account.errors.full_messages.join(", "),
            expires_in: nil
          }
        end
    # rescue StandardError => e
    #     {
    #       success: false,
    #       message: "Signup failed: #{e.message}"
    #     }
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

        user_or_agent = klass.find_by(email: email.downcase.strip)

        puts "👤 Type: #{type}, Lookup: #{klass}, Found: #{user_or_agent&.email}"

        if user_or_agent&.authenticate(password)

          puts "the user is >>> #{user_or_agent} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

          token = JsonWebToken.encode({
            id: user_or_agent.id,
            type: type.upcase, # e.g., "USER" or "AGENT",
            **(user_or_agent.is_a?(Agent) ? { role: user_or_agent.role } : {})
          })

          puts "✅ Authenticated #{type}: #{user_or_agent.inspect}"

          {
            user: type == "user" ? user_or_agent : nil,
            agent: type == "agent" ? user_or_agent : nil,
            token: token,
            success: true,
            message: "Login successful",
            expires_in: 24.hours.to_i
          }
        else
          puts "❌ Invalid login for #{type} with email: #{email}"
          {
            success: false,
            message: "Invalid email or password"
          }
        end
      rescue StandardError => e
        puts "🔥 Exception during login: #{e.message}"
        {
          success: false,
          message: "Login failed: #{e.message}"
        }
      end
    end
  end
end
