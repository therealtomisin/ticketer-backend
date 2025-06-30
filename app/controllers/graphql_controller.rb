# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      current_user: current_user,
      current_agent: current_agent
    }
    result = TicketerBackendSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [ { message: e.message, backtrace: e.backtrace } ], data: {} }, status: 500
  end

  def current_user
    auth_token = request.headers["Authorization"]&.split(" ")&.last
    return nil unless auth_token

  payload = JsonWebToken.decode(auth_token) rescue nil

  puts "the payload is >>> #{payload}"
  return nil unless payload.present? && payload["id"] && !payload["role"] # No role = it's a user

  User.find_by(id: payload["id"])
  end

  def current_agent
    auth_token = request.headers["Authorization"]&.split(" ")&.last
    return nil unless auth_token




  payload = JsonWebToken.decode(auth_token) rescue nil

  puts "the payload is >>> #{payload}"
  return nil unless payload.present? && payload["id"] && payload["role"] # role = it's an agent

  agent = Agent.find_by(id: payload["id"])

  puts "the agent is >>> ID: #{agent&.id}, Name: #{agent&.firstname} #{agent&.lastname}, Email: #{agent&.email}"

  agent
  end
end
