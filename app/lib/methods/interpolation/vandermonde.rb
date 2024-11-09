module Methods::Interpolation::Vandermonde
  class << self
    def exec points
      # Validations
      errors = interpolation_validations points

      return { errors: } unless errors.empty?

      d = points[:x].size
      matrix = Array.new(d)
      _B = Array.new(d)
      _Ai = Array.new(d)
      
      (0..d - 1).each do |i|
        matrix[i] = Array.new(d, 0.0)

        _B[i] = points[:y][i]
        _Ai[i] = ["a_#{i + 1}"]

        (0..d - 1).each do |j|
          matrix[i][j] = points[:x][i] ** (d - j - 1)
        end
      end

      solution = { matrix: Methods::Utils::Matrix.store_matrix(matrix), B: _B }
      gauss_solution = Methods::LinearEquations::GaussEliminationPartial.exec(matrix, _B)

      if gauss_solution[:errors].empty?
        solution[:Pc] = gauss_solution[:result]
      else
        solution[:errors] = gauss_solution[:errors]
      end

      return solution
    end

    def interpolation_validations points
      []
    end
  end
end
