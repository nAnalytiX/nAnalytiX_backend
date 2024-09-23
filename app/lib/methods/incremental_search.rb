module Methods::IncrementalSearch
  class << self
    def exec(func, x0, delta, nmax)
      errors = validations(func, x0, delta, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }
      fx0 = f.call(x0)

      if fx0 == 0
        return { data: [], errors: }
      end

      data = []

      (1..nmax).each do |i|
        x1 = x0 + delta

        begin
          fx1 = f.call(x1)
        rescue StandardError => e
          ap "Error al evaluar f(x1): #{e.message}"
        end

        if fx0 * fx1 < 0
          data << { x0:, x1: }
        end

        x0 = x1
        fx0 = fx1
      end

      if data.empty?
        errors << 'not_found'
      end

      return { data:, errors: }
    end

    private

    def validations func, x0, delta, nmax
      errors = []

      if delta == 0
        errors << 'delta'
      end

      if nmax <= 0
        errors << 'nmax'
      end

      begin
        f = ->(x) { eval(func) }
      rescue StandardError
        errors << 'function_eval'
      end

      errors
    end
  end
end
