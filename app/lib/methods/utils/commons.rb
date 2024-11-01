module Methods::Utils::Commons
  def self.format_function func_string
    func_string = func_string.gsub(/\s+/, '')

    string_chars = func_string.chars
    new_string_chars = []
    acc = ''

    string_chars.each_with_index do |current, index|
      if current.match(/\A-?\d+\Z/)
        acc += current
      else
        if acc != ''
          new_string_chars << acc.to_f.to_s

          acc = ''
        end

        new_string_chars << current
      end

      if index == string_chars.length - 1
        new_string_chars << acc.to_f.to_s
      end
    end

    func_string = new_string_chars.join

    func_string = func_string.gsub(/\bsin\b/, 'Math.sin')
    func_string = func_string.gsub(/\bcos\b/, 'Math.cos')
    func_string = func_string.gsub(/\btan\b/, 'Math.tan')
    func_string = func_string.gsub(/\bexp\b/, 'Math.exp')
    func_string = func_string.gsub(/\log\b/, 'Math.log10')
    func_string = func_string.gsub(/\ln\b/, 'Math.log')
    func_string = func_string.gsub(/\be\b/, 'Math.exp')
    func_string = func_string.gsub(/\bsqrt\b/, 'Math.sqrt')
    func_string = func_string.gsub(/\^/, '**')

  end

  def self.calc_error value_a, value_b, error_type
    if error_type == 'abs'
      return (value_a - value_b).abs
    end

    if error_type == 'rel'
      return ((value_a - value_b).abs / value_a.abs).abs
    end

    0
  end
end
