module Methods::FalsePosition
  class << self
    def exec(func, a, b, tol, nmax)
      errors = validations(func, a, b, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }
      fa = f.call(a)
      fb = f.call(b)

      conclution = nil
      iterations = []

      error = Float::INFINITY
      x_old = b

      (1..nmax).each do |i|
        x_new = b - ((fb * (b - a)) / (fb - fa))
        fx = f.call(x_new)

        if i > 1
          error = ((x_new - x_old).abs / x_new.abs).abs
        end

        iterations << { i:, a:, x: x_new, b:, fa:, fx:, fb:, error: }

        if error < tol
          conclution = { iteration: i, value: x_new }

          break
        end

        if fa * fx < 0
          b = x_new
          fb = fx
        else
          a = x_new
          fa = fx
        end

        x_old = x_new
      end

      errors << 'not_found' if conclution.nil?

      return { conclution:, iterations:, errors: }
    end

    private

    def validations(func, a, b, tol, nmax)
      errors = []

      if tol <= 0
        errors << 'tol'
      end

      if nmax <= 0
        errors << 'nmax'
      end

      begin
        f = ->(x) { eval(func) }
      rescue StandardError
        errors << 'function_eval'
      end

      fa = f.call(a)
      fb = f.call(b)
      
      if fa * fb > 0
        errors << 'interval'
      end

      errors
    end
  end
end


