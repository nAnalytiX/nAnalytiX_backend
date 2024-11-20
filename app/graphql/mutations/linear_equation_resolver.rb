module Mutations
  class LinearEquationResolver < BaseMutation
    # Arguments
    argument :method, String, required: true
    argument :matrix_a, GraphQL::Types::JSON, required: true
    argument :vector_b, GraphQL::Types::JSON, required: true
    argument :vector_x0, GraphQL::Types::JSON, required: false
    argument :tolerance, Float, required: false
    argument :nmax, Int, required: false
    argument :norm, Int, required: false
    argument :w, Float, required: false

    # Response
    field :result, GraphQL::Types::JSON, null: false

    def resolve(method:, **args)
      return unless method.present?
      
      result = []

      matrix_a = JSON.parse(args[:matrix_a])
      vector_b = JSON.parse(args[:vector_b])
      vector_x0 = JSON.parse(args[:vector_x0]) if args[:vector_x0].present?

      result =
        case method
        ## Non Linear Equations
        when 'gauss_simple'
          Methods::LinearEquations::GaussEliminationSimple.exec(matrix_a, vector_b)
        when 'gauss_partial'
          Methods::LinearEquations::GaussEliminationPartial.exec(matrix_a, vector_b)
        when 'gauss_total'
          Methods::LinearEquations::GaussEliminationTotal.exec(matrix_a, vector_b)
        when 'lu_simple'
          Methods::LinearEquations::FactorizationLuSimple.exec(matrix_a, vector_b)
        when 'lu_partial'
          Methods::LinearEquations::FactorizationLuPartial.exec(matrix_a, vector_b)
        when 'crout'
          Methods::LinearEquations::Crout.exec(matrix_a, vector_b)
        when 'doolittle'
          Methods::LinearEquations::Doolittle.exec(matrix_a, vector_b)
        when 'cholesky'
          Methods::LinearEquations::Cholesky.exec(matrix_a, vector_b)
        when 'jacobi'
          Methods::LinearEquations::Jacobi.exec(matrix_a, vector_b, vector_x0, args[:norm], args[:tolerance], args[:nmax])
        when 'gauss'
          Methods::LinearEquations::GaussSeidel.exec(matrix_a, vector_b, vector_x0, args[:norm], args[:tolerance], args[:nmax])
        when 'sor'
          Methods::LinearEquations::Sor.exec(matrix_a, vector_b, vector_x0, args[:norm], args[:w], args[:tolerance], args[:nmax])
        ## Linear Equations
        end

      { result: }
    end
  end
end

