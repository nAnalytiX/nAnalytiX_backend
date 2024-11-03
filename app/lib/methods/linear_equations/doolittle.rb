require 'matrix'

module Methods::LinearEquations::Doolittle
  class << self
    def exec(matrix, vector = [1, 1, 1 ,1])
      @matrix = matrix
      @vector = vector
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
          sol = 0

          (0...i).each do |k|
            sol += _L[i][k] * _U[k][j] 
          end

          _U[i][j] = @matrix[i][j] - sol
        end

        # Calculate U values
        (i + 1...n).each do |j|
          sol = 0

          (0...i).each do |k|
            sol += _L[j][k] * _U[k][i] 
          end

          _L[j][i] = (@matrix[j][i] - sol) /  _U[i][i]
        end

        # Save Iteration
        @iterations << Methods::Utils::Matrix.store_matrices({ L: _L, U: _U})
      end

      # Last Step
      sol = 0
      (0...n - 1).each do |k|
        sol += _L[n - 1][k] * _U[k][n - 1]
      end
      _U[n - 1][n - 1] = @matrix[n - 1][n - 1] - sol

      @iterations << Methods::Utils::Matrix.store_matrices({ L: _L, U: _U})

      # Progressive Sustitution: resolver LY = B
      progressive_result = Methods::Utils::Matrix.progressive_sustitution(_L, @vector)

      # Regresive Sustitution: resolver UX = Y
      regresive_result = Methods::Utils::Matrix.regressive_sustitution(_U, progressive_result)

      solution = Methods::Utils::Matrix.store_vector(regresive_result)

      return { solution:, iterations: @iterations, errors: @errors }
    end
  end
end


