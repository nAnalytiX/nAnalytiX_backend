module Mutations
  class NonLinearEquationResolver < BaseMutation
    # Arguments
    argument :method, String, required: true
    argument :fx, String, required: false
    argument :gx, String, required: false
    argument :derivate, String, required: false
    argument :second_derivate, String, required: false
    argument :interval_a, Float, required: false
    argument :interval_b, Float, required: false
    argument :x0, Float, required: false
    argument :x1, Float, required: false
    argument :delta, Float, required: false
    argument :tolerance, Float, required: false
    argument :nmax, Int, required: false
    argument :error_type, String, required: false

    # Response
    field :result, GraphQL::Types::JSON, null: false

    def resolve(method:, **args)
      return unless method.present?
      
      result = []

      result =
        case method
        ## Non Linear Equations
        when 'incremental_search'
          Methods::NonLinearEquations::IncrementalSearch.exec(args[:fx], args[:x0], args[:delta], args[:nmax])
        when 'bisection'
          Methods::NonLinearEquations::Bisection.exec(args[:fx], args[:interval_a], args[:interval_b], args[:tolerance], args[:nmax], args[:error_type])
        when 'false_position'
          Methods::NonLinearEquations::FalsePosition.exec(args[:fx], args[:interval_a], args[:interval_b], args[:tolerance], args[:nmax], args[:error_type])
        when 'newton'
          Methods::NonLinearEquations::Newton.exec(args[:fx], args[:derivate], args[:x0], args[:tolerance], args[:nmax], args[:error_type])
        when 'multiple_roots'
          Methods::NonLinearEquations::MultipleRoots.exec(args[:fx], args[:derivate], args[:second_derivate], args[:x0], args[:tolerance], args[:nmax], args[:error_type])
        when 'secant'
          Methods::NonLinearEquations::MultipleRoots.exec(args[:fx], args[:x0], args[:x1], args[:tolerance], args[:nmax], args[:error_type])
        when 'fixed_point'
          Methods::NonLinearEquations::MultipleRoots.exec(args[:fx], args[:gx], args[:x0], args[:tolerance], args[:nmax], args[:error_type])

        ## Linear Equations
        end

      { result: }
    end
  end
end
