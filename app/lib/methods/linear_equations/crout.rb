require 'matrix'

module Methods::LinearEquations::Crout
  class << self
    def exec(matrix, vector = [1, 1, 1 ,1])
      @matrix = Methods::Utils::Matrix.matrix_format matrix
      @vector = Methods::Utils::Matrix.vector_format vector
      @errors = []
      @iterations = []

      # Validations
      @errors = Methods::Utils::Matrix.matrix_vector_validations @matrix, @vector

      return { iterations: [], errors: @errors } unless @errors.empty?

      n = matrix.size

      # Initial L and U matrices, with ones in the diagonal and zero in the rest
      _L, _U = Methods::Utils::Matrix.generate_LU_matrix @matrix

      # Step 1
      @iterations << Methods::Utils::Matrix.store_matrices({ L: _L, U: _U})

      (0...n - 1).each do |i|
        # Calculate L values
        (i...n).each do |j|
          prod = 0

          (0...i).each do |k|
            prod += _L[j][k] * _U[k][i] 
          end

          _L[j][i] = @matrix[j][i] - prod
        end

        # Calculate U values
        (i + 1...n).each do |j|
          prod = 0

          (0...i).each do |k|
            prod += _L[i][k] * _U[k][j] 
          end

          _U[i][j] = (@matrix[i][j] - prod) /  _L[i][i]
        end

        # Save Iteration
        @iterations << Methods::Utils::Matrix.store_matrices({ L: _L, U: _U})
      end

      # Last Step
      prod = 0
      (0...n - 1).each do |k|
        prod += _L[n - 1][k] * _U[k][n - 1]
      end
      _L[n - 1][n - 1] = @matrix[n - 1][n - 1] - prod

      @iterations << Methods::Utils::Matrix.store_matrices({ L: _L, U: _U})

      # Progressive Sustitution: resolver LY = B
      progressive_result = Methods::Utils::Matrix.progressive_sustitution(_L, @vector)

      # Regresive Sustitution: resolver UX = Y
      regresive_result = Methods::Utils::Matrix.regressive_sustitution(_U, progressive_result)

      result = Methods::Utils::Matrix.store_vector(regresive_result)

      return { result:, iterations: @iterations, errors: @errors }
    end
  end
end
