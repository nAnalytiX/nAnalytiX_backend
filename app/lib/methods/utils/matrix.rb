module Methods::Utils::Matrix
  def self.matrix_format matrix
    n = matrix.size
    result = Array.new(n) { Array.new(n) }

    n.times do |i|
      n.times do |j|
        result[i][j] = matrix[i][j].to_f
      end
    end

    result
  end

  def self.vector_format vector
    n = vector.size
    result = Array.new(n)

    n.times { |i| result[i] = vector[i].to_f }

    result
  end

  def self.generate_simple_L_matrix matrix
    n = matrix.size
    result = Array.new(n) { Array.new(n, 0.0) }

    n.times { |i| result[i][i] = 1 }

    result
  end

  def self.generate_simple_U_matrix matrix
    n = matrix.size
    result = Array.new(n) { Array.new(n, 0.0) }

    n.times do |i|
      n.times do |j|
        result[i][j] = i == 0 ? matrix[i][j] : 0.0
      end
    end

    result
  end

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

    matrices.each {|key, matrix| new_matrices[key] = store_matrix matrix }

    new_matrices
  end

  def self.store_vector vector
    vector.map { |val| val.class == Complex ? val : sprintf("%0.7f", val) }
  end

  def self.store_matrix matrix
    n = matrix.size
    m = matrix[0].size
    result = Array.new(n) { Array.new(n, 0.0) }

    n.times do |i|
      m.times do |j|
        result[i][j] = matrix[i][j].class == Complex ? matrix[i][j] : sprintf('%0.7f', matrix[i][j])
      end
    end

    result
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
      sum = (0...i).inject(0) { |sum, k| sum + matrix[i][k] * result[k] }
      result[i] = (vector[i] - sum) / matrix[i][i]
    end

    result
  end

  def self.regressive_sustitution matrix, progressive_result
    n = matrix.size
    result = Array.new(n, 0.0)

    (n - 1).downto(0) do |i|
      sum = (i + 1...n).inject(0) { |sum, k| sum + matrix[i][k] * result[k] }
      result[i] = (progressive_result[i] - sum) / matrix[i][i]
    end

    result
  end

  ## For Iterative Methods
 
  def self.generate_diagonal_matrix matrix
    n = matrix.size
    result = Array.new(n) { Array.new(n, 0.0) }

    n.times { |i| result[i][i] = matrix[i][i] }

    result
  end
 
  def self.generate_L_matrix matrix, diagonal
    n = matrix.size
    lower_matrix = Array.new(n) { Array.new(n, 0.0) }
    result = Array.new(n) { Array.new(n, 0.0) }

    (0...n).each do |i|
      (0..i).each do |j|
        lower_matrix[i][j] = matrix[i][j]
      end
    end

    negative_lower_matrix = lower_matrix.map { |row| row.map { |element| element.zero? ? 0.0 : -element } }

    (0...n).each do |i|
      (0...n).each do |j|
        result[i][j] = negative_lower_matrix[i][j] + diagonal[i][j]
      end
    end

    result
  end
 
  def self.generate_U_matrix matrix, diagonal
    n = matrix.size
    upper_matrix = Array.new(n) { Array.new(n, 0.0) }
    result = Array.new(n) { Array.new(n, 0.0) }

    (0...n).each do |i|
      (i...n).each do |j|
        upper_matrix[i][j] = matrix[i][j]
      end
    end

    negative_lower_matrix = upper_matrix.map { |row| row.map { |element| element.zero? ? 0.0 : -element } }

    matrix_add negative_lower_matrix, diagonal
  end
 
  def self.print_matrix(matrix)
    matrix.each { |row| puts row.map { |val| sprintf("%0.3f", val) }.join(" ") }
  end
 
  def self.matrix_inverse matrix
    m = Matrix[*matrix]

    m.inverse.to_a
  end
 
  def self.matrix_add matrix_a, matrix_b
    m_a = Matrix[*matrix_a]
    m_b = Matrix[*matrix_b]

    (m_a + m_b).to_a
  end
 
  def self.matrix_substract matrix_a, matrix_b
    m_a = Matrix[*matrix_a]
    m_b = Matrix[*matrix_b]

    (m_a - m_b).to_a
  end
 
  def self.matrix_multiply matrix_a, matrix_b
    m_a = Matrix[*matrix_a]
    m_b = Matrix[*matrix_b]

    (m_a * m_b).to_a
  end
 
  def self.matrix_vector_multiply matrix, vector
    n = matrix.size
    result = Array.new(n, 0.0)

    (0...n).each do |i|
      result[i] = (0...vector.size).inject(0) { |sum, j| sum + matrix[i][j] * vector[j] }
    end

    result
  end
 
  def self.vector_add vector_a, vector_b
    result = Array.new(vector_a.size)

    vector_a.size.times do |i|
      result[i] = vector_a[i] + vector_b[i]
    end

    result
  end
 
  def self.vector_substract vector_a, vector_b
    result = Array.new(vector_a.size)

    vector_a.size.times do |i|
      result[i] = vector_a[i] - vector_b[i]
    end

    result
  end

 
  def self.generate_spectral_radius matrix
    matrix = Matrix[*matrix]

    eigen_decomp = matrix.eigen
    eigenvalues = eigen_decomp.eigenvalues.to_a
    spectral_radius = eigenvalues.map(&:abs).max

    spectral_radius
  end
 
  def self.generate_vector_norma vector, norma
    case norma
    when 1
      vector.reduce(0) { |sum, x| sum + x.abs }
    when 2
      Math.sqrt(vector.reduce(0) { |sum, x| sum + x**2 })
    when 3
     (vector.map { |x| x.abs**3 }.sum) ** (1.0 / 3.0) 
    when 'infinite'
      vector.map(&:abs).max
    end
  end
end
