require 'matrix'

module Methods::LinearEquations::FactorizationLuSimple
  class << self
    def exec(matrix, vector = [1, 1, 1 ,1])
      @matrix = matrix
      @vector = vector
      @errors = []
      @iterations = []

      @errors = Methods::Utils::Matrix.matrix_vector_validations @matrix, @vector

      return { iterations: [], errors: @errors } unless @errors.empty?
      n = matrix.size

      _L = Methods::Utils::Matrix.generate_L_matrix @matrix
      _U = Methods::Utils::Matrix.generate_U_matrix @matrix

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

      solution = Methods::Utils::Matrix.store_vector(regresive_result)

      return { iterations: @iterations, solution: solution, errors: @errors }
    end

    private

    def generate_L_matrix matrix
      n = matrix.size
      result = Array.new(n) { Array.new(n, 0.0) }

      n.times { |i| result[i][i] = 1 }

      result
    end

    def generate_U_matrix matrix
      n = matrix.size
      result = Array.new(n) { Array.new(n, 0.0) }

      n.times do |i|
        n.times do |j|
          result[i][j] = i == 0 ? matrix[i][j] : 0.0
        end
      end

      result
    end

    def initial_validations
      begin
        matrix = Matrix[*@matrix]
      rescue
        @errors << 'matrix'
      end

      begin
        vector = Matrix[@vector]
      rescue
        @errors << 'vector'
      end

      return unless @errors.empty?

      ## Validate Matrix Determinant
      if matrix.determinant == 0
        @errors << 'matrix_determinant'
      end

      ## Validate Matrix Square
      if !matrix.square?
        @errors << 'matrix_square'
      end

      ## Validate Vector B has 1 column
      if vector.row_size != 1
        @errors << 'vector_column'
      end

      ## Validate Matrix A and Vector B has the same dimensions
      if matrix.row_size != vector.column_size
        @errors << 'different_dimensions'
      end
    end
  end
end

