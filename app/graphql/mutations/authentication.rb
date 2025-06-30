module Mutations
  module Authentication
class Signup < BaseMutation
  argument :email, String, required: true
  argument :password, String, required: true
  argument :firstname, String, required: true
  argument :lastname, String, required: true
  argument :type, String, required: true # "user" or "agent"
  argument :role, String, required: false # Only for agents

  field :token, String, null: true
  field :success, Boolean, null: false
  field :message, String, null: true
  field :expires_in, Integer, null: true

  def resolve(email:, password:, firstname:, lastname:, type:, role: nil)
    email = email.strip.downcase
    firstname = firstname.strip
    lastname = lastname.strip

    # Validate inputs
    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      return { success: false, message: "Invalid email format" }
    end

    if password.length < 6
      return { success: false, message: "Password must be at least 6 characters long" }
    end

    unless %w[user agent].include?(type.downcase)
      return { success: false, message: "Invalid user type. Must be 'user' or 'agent'" }
    end

    model = type.downcase == "user" ? User : Agent

    if model.exists?(email: email)
      return {
        success: false,
        message: "#{type.capitalize} with this email already exists"
      }
    end

    account = model.new(
      email: email,
      password: password,
      firstname: firstname,
      lastname: lastname
    )

    account.role = role.presence || "ADMIN" if model == Agent

    if account.save
      verification_code = rand(10000..99999).to_s

      token = JsonWebToken.encode({ code: verification_code, type: type, id: account.id }, 30.minutes.from_now.to_i)

      UserMailer.welcome_email(account, verification_code).deliver_now

      {
        token: token,
        user: type == "agent" ? nil : account,
        agent: type == "user" ? nil : account,
        success: true,
        message: "Account created successfully",
        expires_in: 30.minutes.to_i
      }
    else
      {
        success: false,
        message: account.errors.full_messages.join(", "),
        token: nil,
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
    email = email.strip.downcase

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      return { success: false, message: "Invalid email format" }
    end

    if password.blank?
      return { success: false, message: "Password is required" }
    end

    klass = case type.downcase
    when "user" then User
    when "agent" then Agent
    else
              return { success: false, message: "Invalid type provided: must be 'user' or 'agent'" }
    end

    account = klass.find_by(email: email)

    if account&.authenticate(password)
      unless account.isVerified
        verification_code = rand(10000..99999).to_s

        token = JsonWebToken.encode({
          code: verification_code,
          type: type,
          id: account.id
        }, 30.minutes.from_now.to_i)

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

      {
        user: type == "user" ? account : nil,
        agent: type == "agent" ? account : nil,
        token: token,
        success: true,
        message: "Login successful",
        expires_in: 24.hours.to_i
      }
    else
      {
        success: false,
        message: "Invalid email or password",
        token: nil,
        expires_in: nil,
        user: nil,
        agent: nil
      }
    end
  rescue => e
    {
      success: false,
      message: "Login failed: #{e.message}",
      token: nil,
      expires_in: nil,
      user: nil,
      agent: nil
    }
  end
end

class VerifyToken < BaseMutation
  argument :code, String, required: true
  argument :token, String, required: true

  field :user, Types::UserType, null: true
  field :agent, Types::AgentType, null: true
  field :success, Boolean, null: false
  field :message, String, null: true

  def resolve(code:, token:)
    decoded = JsonWebToken.decode(token)

    puts "the decoded is >>> #{decoded}"

    actual_code = decoded["code"]
    user_type = decoded["type"]&.downcase
    account_id = decoded["id"]

    unless actual_code && user_type && account_id
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

    klass = case user_type
    when "user" then User
    when "agent" then Agent
    else
              raise GraphQL::ExecutionError, "Unknown user type: #{user_type}"
    end

    account = klass.find_by(id: account_id)

    unless account
      return {
        success: false,
        message: "#{user_type.capitalize} not found",
        user: nil,
        agent: nil
      }
    end

    # ✅ Mark the user/agent as verified and save
    account.update!(isVerified: true)

    {
      success: true,
      message: "Verification successful",
      user: user_type == "user" ? account : nil,
      agent: user_type == "agent" ? account : nil
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
