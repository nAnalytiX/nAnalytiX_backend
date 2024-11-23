module Mutations
  class InterpolationResolver < BaseMutation
    # Arguments
    argument :method, String, required: true
    argument :points, GraphQL::Types::JSON, required: true

    # Response
    field :result, GraphQL::Types::JSON, null: false

    def resolve(method:, **args)
      return unless method.present?
      
      result = []

      points = JSON.parse(args[:points])

      result =
        case method
        ## Non Linear Equations
        when 'vandermonde'
          Methods::Interpolation::Vandermonde.exec(points)
        when 'newton'
          Methods::Interpolation::Newton.exec(points)
        when 'lagrange'
          Methods::Interpolation::Lagrange.exec(points)
        when 'spline_linear'
          Methods::Interpolation::SplineLinear.exec(points)
        when 'spline_cuadratic'
          Methods::Interpolation::SplineCuadratic.exec(points)
        when 'spline_cubic'
          Methods::Interpolation::SplineCubic.exec(points)
        end

      { result: }
    end
  end
end

