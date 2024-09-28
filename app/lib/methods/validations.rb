module Methods::Validations

  def self.function function, name = 'function', variables = {}, errors
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

  def self.a_interval interval, errors
    unless interval.is_a? Numeric
      errors << 'a_interval'
    end

    return errors
  end

  def self.b_interval interval, errors
    unless interval.is_a? Numeric
      errors << 'b_interval'
    end

    return errors
  end

  def self.x0_value value, errors
    unless value.is_a? Numeric
      errors << 'x0_interval'
    end

    return errors
  end
end
