require 'matrix'

module Methods::LinearEquations::GaussEliminationSimple
  class << self
    def exec(matrix_a, vector_b = [1, 1, 1, 1])
      matrix = Methods::Utils::Matrix.matrix_format matrix_a
      vector = Methods::Utils::Matrix.vector_format vector_b
      errors = []
      iterations = []

      errors = Methods::Utils::Matrix.matrix_vector_validations matrix, vector

      return { result: nil, iterations: [], errors: } unless errors.empty?

      a = matrix
      b = vector

      n = matrix.size

      a = a.map.with_index { |line, i| line + [vector[i]] }

      (0..(n - 1)).each do |i|
        iterations << { step: i, matrix: Methods::Utils::Matrix.store_matrix(a) }

        if a[i][i] == 0
          (i + 1..n).each do |j|
            if a[i][j] != 0
              aux = Array.new(n + 1)

              (i...n).each do |k|
                aux[k] = a[j][k]
                a[j][k] = a[i][k]
                a[i][k] = aux[k]
              end

              break
            end

          end
        end

        ((i + 1)..(n)).each do |j|
          if a[i][j] != 0
            aux = Array.new(n + 1)

            (i...n).each do |k|
              aux[k] = a[j][k] - (a[j][i] / a [i][i]) * a[i][k]
            end

            (i...n).each do |k|
              a[j][k] = aux[k] 
            end
          end
        end
      end

      solution = Array.new(n)
      (n - 1).downto(0) do |i|
        solution[i] = a[i][n]
        (i + 1...n).each do |j|
          solution[i] -= a[i][j] * solution[j]
        end
      end

      return { result: solution, iterations: iterations, errors: errors }
    end
  end
end
