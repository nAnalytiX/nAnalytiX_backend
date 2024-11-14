require 'matrix'

module Methods::LinearEquations::FactorizationLuPartial
  class << self
    def exec(matrix, vector = [1, 1, 1 ,1])
      @matrix = matrix
      @vector = vector
      @errors = []
      @iterations = []

      @errors = Methods::Utils::Matrix.matrix_vector_validations @matrix, @vector

      return { iterations: [], errors: @errors } unless @errors.empty?

      n = matrix.size

      _L = Methods::Utils::Matrix.generate_simple_L_matrix @matrix
      _U = Methods::Utils::Matrix.generate_simple_U_matrix @matrix
      _P = Methods::Utils::Matrix.generate_simple_L_matrix @matrix

      _M = @matrix.map(&:dup)

      @iterations << Methods::Utils::Matrix.store_matrices({ M: _M, L: _L, U: _U})

      (0...n - 1).each do |i|
        pivot_row = (i...n).max_by { |r| _M[r][i].abs }

        if _M[pivot_row][i].zero?
          @errors << 'zero_in_diagonal'
          
          break
        end

        if pivot_row != i
          _M[i], _M[pivot_row] = _M[pivot_row], _M[i]
          _P[i], _P[pivot_row] = _P[pivot_row], _P[i]

          (0...i).each do |k|
            _L[i][k], _L[pivot_row][k] = _L[pivot_row][k], _L[i][k]
          end
        end

        (i + 1...n).each do |j|
          if _M[j][i] != 0
            factor = _M[j][i] / _M[i][i]
            _L[j][i] = factor

            temp = Array.new(n, 0)

            (i...n).each do |k|
              temp[k] = _M[j][k] - factor * _M[i][k]
            end

            (i...n).each do |k|
              _M[j][k] = temp[k]
            end
          end
        end

        (i...n).each do |j|
          _U[i][j] = _M[i][j];
        end

        (i + 1...n).each do |j|
          _U[i + 1][j] = _M[i + 1][j];
        end

        @iterations << Methods::Utils::Matrix.store_matrices({ M: _M, L: _L, U: _U})
      end

      # Progressive Sustitution: resolver LY = B
      progressive_result = Methods::Utils::Matrix.progressive_sustitution(_L, @vector)

      # Regresive Sustitution: resolver UX = Y
      regresive_result = Methods::Utils::Matrix.regressive_sustitution(_U, progressive_result)

      solution = Methods::Utils::Matrix.store_vector(regresive_result)

      return { iterations: @iterations, solution: solution, errors: @errors }
    end
  end
end
