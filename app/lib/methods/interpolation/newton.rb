module Methods::Interpolation::Newton
  class << self
    def exec points
      # Validations
      points = Methods::Utils::Points.format_points_v2(points)
      errors = Methods::Utils::Points.validate_points_v2(points) 

      return { errors: } unless errors.empty?

      n = points.size
      exp = ""
      table = Array.new(n) { Array.new(n, 0) }

      # Initialize the first column with y values
      n.times { |i| table[i][0] = points[i][1] }

      # Calculate the divided differences
      (1...n).each do |j|
        (0...(n - j)).each do |i|
          table[i][j] = (table[i + 1][j - 1] - table[i][j - 1]) / (points[i + j][0] - points[i][0])
        end
      end

      newton_coefficients = table[0]  # The first row contains the polynomial newton_coefficients

      # Construct the polynomial in lambda format to evaluate at any x
      lambda do |x|
        result = newton_coefficients[0]
        (1...n).each do |i|
          term = newton_coefficients[i]
          (0...i).each { |j| term *= (x - points[j][0]) }
          result += term
        end
        result
      end

      return { table: Methods::Utils::Matrix.store_matrix(table), newton_coefficients: }
    end

  end
end

