module Methods::Interpolation::SplineLinear
  class << self
    def exec points
      # Validations
      errors = Methods::Utils::Validations.interpolation points

      return { errors: } unless errors.empty?

      n = points.size
      m = 2 * (n - 1)
      matrix_a = Array.new(m) { Array.new(m, 0.0) }
      vector_b = Array.new(m, 0.0)

      (0...n - 1).each do |i|
        matrix_a[i + 1][2 * i] = points[i + 1][0]
        matrix_a[i + 1][2 * i + 1] = 1
        vector_b[i + 1] = points[i + 1][1]
      end

      matrix_a[0][0] = points[0][0]
      matrix_a[0][1] = 1
      vector_b[0] = points[0][1]

      (1...n - 1).each do |i|
        matrix_a[n - 1 + i][2 * i - 2] = points[i][0]
        matrix_a[n - 1 + i][2 * i - 1] = 1
        matrix_a[n - 1 + i][2 * i] = points[i][0] * -1.0
        matrix_a[n - 1 + i][2 * i + 1] = -1.0
        vector_b[n - 1 + i] = 0
      end

      gauss_solution = Methods::LinearEquations::GaussEliminationPartial.exec(matrix_a, vector_b)

      if gauss_solution[:errors].empty?
        result = gauss_solution[:result]
      else
        return { errors: gauss_solution[:errors] }
      end

      polynomials = []
      coefficients = []
      (0..(result.size - 1) / 2).each do |i|
        polynomials << "#{result[i * 2]}x + #{result[i * 2 + 1]}"
        coefficients << [result[i * 2], result[i * 2 + 1]]
      end

      return { polynomials: , coefficients: }
    end
  end
end
