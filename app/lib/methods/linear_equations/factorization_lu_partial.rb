require 'matrix'

module Methods::LinearEquations::FactorizationLuPartial
  class << self
    def exec(matrix, vector = [1, 1, 1 ,1])
      @matrix = matrix
      @vector = vector
      @errors = []
      @iterations = []

      initial_validations()

      return { iterations: [], errors: @errors } unless @errors.empty?

      n = matrix.size

      _L = generate_L_matrix @matrix
      _U = generate_U_matrix @matrix
      _P = generate_L_matrix @matrix

      _M = @matrix.map(&:dup)

      @iterations << { M: store_matrix(_M), L: store_matrix(_L), U: store_matrix(_U), P: store_matrix(_P) }

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

        @iterations << { M: store_matrix(_M), L: store_matrix(_L), U: store_matrix(_U), P: store_matrix(_P) }
      end

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

      x = x.map { |val| sprintf("%0.7f", val) }

      return { iterations: @iterations, solution: x, errors: @errors }
    end

    private

    def print_matrix(matrix)
      matrix.each { |row| puts row.map { |val| sprintf("%0.6f", val) }.join(" ") }
    end

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

    def store_matrix matrix
      n = matrix.size
      result = Array.new(n) { Array.new(n, 0.0) }

      n.times do |i|
        n.times do |j|
          result[i][j] = sprintf('%0.7f', matrix[i][j])
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


