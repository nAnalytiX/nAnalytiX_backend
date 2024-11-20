require 'matrix'

module Methods::LinearEquations::FactorizationLuSimple
  class << self
    def exec(matrix, vector = [1, 1, 1 ,1])
      @matrix = Methods::Utils::Matrix.matrix_format matrix
      @vector = Methods::Utils::Matrix.vector_format vector
      @errors = []
      @iterations = []

      @errors = Methods::Utils::Matrix.matrix_vector_validations @matrix, @vector

      return { iterations: [], errors: @errors } unless @errors.empty?
      n = matrix.size

      _L = Methods::Utils::Matrix.generate_simple_L_matrix @matrix
      _U = Methods::Utils::Matrix.generate_simple_U_matrix @matrix

      _M = @matrix.map(&:dup)

      @iterations << Methods::Utils::Matrix.store_matrices({ M: _M, L: _L, U: _U})

      (0...n - 1).each do |i|
        if _M[i][i].zero?
          @errors << 'zero_in_diagonal'
          
          break
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

      result = Methods::Utils::Matrix.store_vector(regresive_result)

      return { iterations: @iterations, result: result, errors: @errors }
    end
  end
end
