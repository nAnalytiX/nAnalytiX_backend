require 'matrix'

module Methods::LinearEquations::GaussEliminationSimple
  class << self
    def exec(matrix_a, vector_b)
      @matrix_a = matrix_a
      @vector_b = vector_b
      @errors = []
      @iterations = []

      initial_validations()

      return { result: nil, iterations: [], errors: @errors } unless @errors.empty?

      a = @matrix_a
      b = @vector_b
      n = @matrix_a.size

      (0..n-1).each do |k|
        @iterations << { step: k, matrix: a.map(&:dup), vector: b.dup }

        if a[k][k] == 0
          raise 'error'
        end

        (k+1...n).each do |i|
          factor = a[i][k].to_f / a[k][k].to_f
          (k...n).each do |j|
            a[i][j] -= factor * a[k][j]
          end
          b[i] -= factor * b[k]
        end
      end

      res = Array.new(n, 0)

      (n-1).downto(0) do |i|
        sum = 0
        ((i+1)...n).each do |j|
          sum += a[i][j] * res[j]
        end
        if a[i][i] == 0
          @errors << 'no_pivot_sustitution'

          break
        end
        res[i] = (b[i] - sum) / a[i][i]
      end

      return { result: res, iterations: @iterations, errors: @errors }
    end

    private

    def initial_validations
      begin
        matrix_a = Matrix[*@matrix_a]
      rescue
        @errors << 'matrix_a'
      end

      begin
        vector_b = Matrix[@vector_b]
      rescue
        @errors << 'vector_b'
      end

      return unless @errors.empty?

      ## Validate Matrix Determinant
      if matrix_a.determinant == 0
        @errors << 'matrix_determinant'
      end

      ## Validate Matrix Square
      if !matrix_a.square?
        @errors << 'matrix_square'
      end

      ## Validate Vector B has 1 column
      if vector_b.row_size != 1
        @errors << 'vector_column'
      end

      ## Validate Matrix A and Vector B has the same dimensions
      if matrix_a.row_size != vector_b.column_size
        @errors << 'different_dimensions'
      end
    end
  end
end
