# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :non_linear_equation_resolver, mutation: Mutations::NonLinearEquationResolver, camelize: true
  end
end
