require 'matrix'

module Methods::LinearEquations::Jacobi
  class << self
    def exec(matrix, vector, x0, norm, tolerance = 0.0000001, nmax = 100)
      errors = []
      iterations = []

      # Validations
      errors = Methods::Utils::Matrix.matrix_vector_validations matrix, vector

      return { iterations:, errors: } unless errors.empty?

      n = matrix.size

      # Define Initial Matrices
      _D = Methods::Utils::Matrix.generate_diagonal_matrix matrix
      _L = Methods::Utils::Matrix.generate_L_matrix matrix, _D
      _U = Methods::Utils::Matrix.generate_U_matrix matrix, _D

      # Jacobi Logic
      ##_T = matrix_multiply(matrix_inverse(matrix_substract(_D, _L)), _U) Gauss
      _T = Methods::Utils::Matrix.matrix_multiply(Methods::Utils::Matrix.matrix_inverse(_D), Methods::Utils::Matrix.matrix_add(_L, _U))
      _C = Methods::Utils::Matrix.matrix_vector_multiply(Methods::Utils::Matrix.matrix_inverse(_D), vector)

      # Calculate Spectral Radius
      spectral_radius = Methods::Utils::Matrix.generate_spectral_radius _T

      result = {
        spectral_radius:,
        T: Methods::Utils::Matrix.store_matrix(_T),
        C: Methods::Utils::Matrix.store_vector(_C),
        errors: [],
      }

      if spectral_radius > 1
        result[:errors] << 'spectral_radius'

        return result
      end

      x0_old = x0.dup

      iterations << { iteration: 0, error: nil, value: x0 }

      (1..nmax).each do |i|
        x = Methods::Utils::Matrix.vector_add(Methods::Utils::Matrix.matrix_vector_multiply(_T, x0_old), _C)
        error = Methods::Utils::Matrix.generate_vector_norma(Methods::Utils::Matrix.vector_substract(x0_old, x), norm)

        iterations << { iteration: i, error: error, value: x }

        if error < tolerance
          break
        end

        x0_old = x
      end

      result[:iterations] = iterations 

      result 
    end
  end
end
