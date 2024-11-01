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
      y = Array.new(n, 0.0)
      (0...n).each do |i|
        y[i] = @vector[i]

        (0...i).each { |j| y[i] -= _L[i][j] * y[j] }
      end

      # Regresive Sustitution: resolver UX = Y
      x = Array.new(n, 0.0)
      (n - 1).downto(0) do |i|
        x[i] = (y[i] - (i + 1...n).sum { |k| _U[i][k] * x[k] }) / _U[i][i]
      end

      solution = Methods::Utils::Matrix.store_vector(x)

      return { solution:, iterations: @iterations, errors: @errors }
    end
  end
end


