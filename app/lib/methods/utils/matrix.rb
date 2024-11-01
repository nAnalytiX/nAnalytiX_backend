module Methods::Utils::Matrix
  def self.generate_LU_matrix matrix
    n = matrix.size
    l = Array.new(n) { Array.new(n, 0.0) }
    u = Array.new(n) { Array.new(n, 0.0) }

    (0...n).each do |i|
      l[i][i] = 1
      u[i][i] = 1
    end

    return l, u
  end

  def self.store_matrices matrices
    new_matrices = Hash.new

    matrices.each do |key, matrix|
      n = matrix.size
      result = Array.new(n) { Array.new(n, 0.0) }

      n.times do |i|
        n.times do |j|
          result[i][j] = matrix[i][j].class == Complex ? matrix[i][j] : sprintf('%0.7f', matrix[i][j])
        end
      end

      new_matrices[key] = result
    end

    new_matrices
  end

  def self.store_vector vector
    vector.map { |val| val.class == Complex ? val : sprintf("%0.7f", val) }
  end


  def self.matrix_vector_validations initial_matrix, initial_vector
    errors = []

    begin
      matrix = Matrix[*initial_matrix]
    rescue
      errors << 'matrix'
    end

    begin
      vector = Matrix[initial_vector]
    rescue
      errors << 'vector'
    end

    return errors unless errors.empty?

    ## Validate Matrix Determinant
    if matrix.determinant == 0
      errors << 'matrix_determinant'
    end

    ## Validate Matrix Square
    if !matrix.square?
      errors << 'matrix_square'
    end

    ## Validate Vector B has 1 column
    if vector.row_size != 1
      errors << 'vector_column'
    end

    ## Validate Matrix A and Vector B has the same dimensions
    if matrix.row_size != vector.column_size
      errors << 'different_dimensions'
    end

    errors
  end

  def self.progressive_sustitution matrix, vector
    n = matrix.size
    result = Array.new(n, 0.0)

    (0...n).each do |i|
      result[i] = vector[i]

      (0...i).each { |j| result[i] -= matrix[i][j] * result[j] }
    end

    result
  end

  def self.regressive_sustitution matrix, progressive_result
    n = matrix.size
    result = Array.new(n, 0.0)

    (n - 1).downto(0) do |i|
      result[i] = (progressive_result[i] - (i + 1...n).sum { |k| matrix[i][k] * result[k] }) / matrix[i][i]
    end

    result
  end
end
