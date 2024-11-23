# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :non_linear_equation_resolver, mutation: Mutations::NonLinearEquationResolver, camelize: true
    field :linear_equation_resolver, mutation: Mutations::LinearEquationResolver, camelize: true
    field :interpolation_resolver, mutation: Mutations::InterpolationResolver, camelize: true
  end
end
