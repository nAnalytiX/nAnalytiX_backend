require 'matrix'

module Methods::LinearEquations::GaussEliminationPartial
  class << self
    def exec(matrix_a, vector_b)
      matrix = Methods::Utils::Matrix.matrix_format matrix_a
      vector = Methods::Utils::Matrix.vector_format vector_b
      errors = []
      iterations = []

      errors = Methods::Utils::Matrix.matrix_vector_validations matrix, vector

      return { result: nil, iterations: [], errors: } unless errors.empty?

      a = matrix
      b = vector

      n = matrix.size

      (0..n - 1).each do |k|
        iterations << { step: k,
                        matrix: Methods::Utils::Matrix.store_matrix(a),
                        vector: Methods::Utils::Matrix.store_vector(b)
                      }

        max_index = (k...n).max_by { |i| a[i][k].abs }

        if k != max_index
          a[k], a[max_index] = a[max_index], a[k]
          b[k], b[max_index] = b[max_index], b[k]
        end

        if a[k][k] == 0
          errors << 'error'

          break
        end

        (k+1...n).each do |i|
          factor = a[i][k].to_f / a[k][k].to_f
          (k...n).each do |j|
            a[i][j] -= factor * a[k][j]
          end
          b[i] -= factor * b[k]
        end
      end

      result = Array.new(n, 0)

      (n - 1).downto(0) do |i|
        sum = 0
        ((i+1)...n).each do |j|
          sum += a[i][j] * result[j]
        end

        if a[i][i] == 0
          errors << 'no_pivot_sustitution'

          break
        end

        result[i] = (b[i] - sum) / a[i][i]
      end

      return { result: Methods::Utils::Matrix.store_vector(result), iterations: , errors: }
    end
  end
end
