module Methods::Interpolation::Lagrange
  class << self
    def exec points
      points = Methods::Utils::Points.format_points_v2(points)
      errors = Methods::Utils::Points.validate_points_v2(points) 

      return { errors: } unless errors.empty?

      n = points.size
      polynomials = []

      (0...n).each do |i|
        numerator = ""
        denominator = ""

        (0...n).each do |j|
          next if j == i

          if points[j][0] < 0 
            numerator += "(x + #{-1.0 * points[j][0]} )"

            if points[i][0] == 0
              denominator += "(#{points[j][0]})"
            else
              denominator += "(#{points[i][0]} + #{points[j][0] * -1.0})"
            end
          elsif points[j][0] > 0
            numerator += "(x - #{points[j][0]})"

            if points[i][0] == 0
              denominator += "(#{points[j][0]})"
            else
              denominator += "(#{points[i][0]} - #{points[j][0]})"
            end
          else
            numerator += "(x)"

            if points[i][0] != 0
              denominator += "(#{points[i][0]})"
            end
          end
        end

        polynomials << "(" + numerator + ") / (" + denominator + ")"
      end

      polynom = []
      polynomials.each_with_index { |poly, index| polynom << "(#{points[index][1]} * #{poly})" }
      polynom = polynom.join(' + ')

      { polynomials:, polynom: }
    end

    def interpolation_validations points
      errors = []

      if points.empty?
        errors << 'points-empty'

        return errors
      end

      if points.length < 1
        errors << 'points-number'

        return errors
      end

      points.each do |point|
        errors << 'points-malformed' unless point.is_a?(Array) && point.size == 2
      end

      xs = points.map { |p| p[0] }
      errors << 'x-distinct' if xs.uniq.size != xs.size

      errors
    end
  end
end

