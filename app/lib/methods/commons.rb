module Methods::Commons
  def self.format_function func_string
    func_string = func_string.gsub(/\bsin\b/, 'Math.sin')
    func_string = func_string.gsub(/\bcos\b/, 'Math.cos')
    func_string = func_string.gsub(/\btan\b/, 'Math.tan')
    func_string = func_string.gsub(/\bexp\b/, 'Math.exp')
    func_string = func_string.gsub(/\be\b/, 'Math.exp')
    func_string = func_string.gsub(/\bsqrt\b/, 'Math.sqrt')
    func_string = func_string.gsub(/\^/, '**')

    func_string
  end
end
