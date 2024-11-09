module Methods::Utils::Validations

  def self.function function, error_name = 'function', variables = {}, errors
    begin
      f = ->(x) { eval(function) }
    rescue
      errors << "#{error_name}_evaluation"

      return errors
    end

    variables.each do |key, value|
      f.call(value) rescue errors << "#{error_name}_evaluation_#{key}"
    end

    errors
  end

  def self.delta delta, errors
    if !delta.present? && tol <= 0
      errors << 'delta'
    end

    return errors
  end

  def self.tolerance tolerance, errors
    if !tolerance.present? && tol <= 0
      errors << 'tolerance'
    end

    return errors
  end

  def self.max_iterations max_iterations, errors
    if !max_iterations.present? && tol <= 0
      errors << 'max_iterations'
    end

    return errors
  end

  def self.numeric_value value, name, errors
    unless value.is_a? Numeric
      errors << name
    end

    return errors
  end

  def self.interpolation points
    errors = []

    if points.empty?
      errors << 'points-empty'

      return errors
    end

    if points.length < 1
      errors << 'points-number'

      return errors
    end

    points.each do |point|
      errors << 'points-malformed' unless point.is_a?(Array) && point.size == 2
    end

    xs = points.map { |p| p[0] }
    errors << 'x-distinct' if xs.uniq.size != xs.size

    errors
  end
end
