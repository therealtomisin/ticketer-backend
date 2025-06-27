# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def authenticated_user!
      context[:current_user] || context[:current_agent] || raise(GraphQL::ExecutionError, "Authentication required")
    end
  end
end
