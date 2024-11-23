module Methods::Interpolation::SplineCuadratic
  class << self
    def exec points
      # Validations
      points = Methods::Utils::Points.format_points_v2(points)
      errors = Methods::Utils::Points.validate_points_v2(points) 

      return { errors: } unless errors.empty?

      n = points.size
      m = 3 * (n - 1)
      matrix_a = Array.new(m) { Array.new(m, 0.0) }
      vector_b = Array.new(m, 0.0)

      (0...n - 1).each do |i|
        matrix_a[i + 1][3 * (i + 1) - 3] = points[i + 1][0] ** 2.0
        matrix_a[i + 1][3 * (i + 1) - 2] = points[i + 1][0]
        matrix_a[i + 1][3 * (i + 1) - 1] = 1.0

        vector_b[i + 1] = points[i + 1][1]
      end

      matrix_a[0][0] = points[0][0] ** 2.0
      matrix_a[0][1] = points[0][0]
      matrix_a[0][2] = 1

      vector_b[0] = points[0][1]

      (1...n - 1).each do |i|
        matrix_a[n - 1 + i][3 * i - 3] = points[i][0] ** 2.0
        matrix_a[n - 1 + i][3 * i - 2] = points[i][0]
        matrix_a[n - 1 + i][3 * i - 1] = 1.0
        matrix_a[n - 1 + i][3 * i] = (points[i][0] ** 2.0) * -1.0
        matrix_a[n - 1 + i][3 * i + 1] = points[i][0] * -1.0
        matrix_a[n - 1 + i][3 * i + 2] = -1.0

        vector_b[n - 1 + i] = 0
      end

      (1...n - 1).each do |i|
        matrix_a[2 * n - 3 + i][3 * i - 3] = points[i][0] ** 2.0
        matrix_a[2 * n - 3 + i][3 * i - 2] = 1.0
        matrix_a[2 * n - 3 + i][3 * i - 1] = 0
        matrix_a[2 * n - 3 + i][3 * i] = -2.0 * points[i][0]
        matrix_a[2 * n - 3 + i][3 * i + 1] = -1
        matrix_a[2 * n - 3 + i][3 * i + 2] = 0

        vector_b[2 * n - 3 + i] = 0
      end

      matrix_a[m - 1][0] = 2
      vector_b[m - 1] = 0

      gauss_solution = Methods::LinearEquations::GaussEliminationPartial.exec(matrix_a, vector_b)

      if gauss_solution[:errors].empty?
        result = gauss_solution[:result]
      else
        return { errors: gauss_solution[:errors] }
      end

      polynomials = []
      coefficients = []
      (0..(result.size - 1) / 3).each do |i|
        polynomials << "#{result[i * 3]}x^2 + #{result[i * 3 + 1]}x + #{result[i * 3 + 2]}"
        coefficients << [result[i * 3], result[i * 3 + 1], result[i * 3 + 2]]
      end

      return { polynomials: , coefficients: }
    end
  end
end

