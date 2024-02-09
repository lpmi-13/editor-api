# frozen_string_literal: true

module GraphqlQueryHelpers
  def execute_query(query:, context: query_context, variables: {})
    EditorApiSchema.execute(query:, context:, variables:).as_json
  end

  def query_context
    context =
      if defined?(current_user)
        { current_user:, current_ability: Ability.new(current_user) }
      else
        { current_user: nil, current_ability: Ability.new(nil) }
      end

    if defined?(remix_origin)
      { **context, remix_origin: }
    else
      { **context, remix_origin: nil }
    end
  end
end
