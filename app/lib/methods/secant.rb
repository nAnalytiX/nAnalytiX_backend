module Methods::Secant
  class << self
    def exec(func, x0, x1, tol, nmax)
      errors = validations(func, x0, x1, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }

      conclution = nil
      iterations = []

      error = Float::INFINITY

      (1..nmax).each do |i|
        f_x0 = f.call(x0)
        f_x1 = f.call(x1)

        if f_x1 - f_x0 == 0
          errors << 'divide_by_zero'

          break
        end

        x_new = x1 - f_x1 * (x1 - x0) / (f_x1 - f_x0)

        if i > 1
          error = ((x_new - x1).abs / x_new.abs).abs
        end

        iterations << { i:, x: x_new, fx: f_x1, error: }

        if x_new == 0
          conclution = { iteration: i, valu: x_new, found: true }

          break
        end

        if error < tol
          conclution = { iteration: i, value: x_new, found: false }

          break
        end

        x0 = x1
        x1 = x_new
      end

      errors << 'not_found' if conclution.nil?

      return { conclution:, iterations:, errors: }
    end

    private

    def validations(func, x0, x1, tol, nmax)
      errors = []

      if x0 == x1
        errors << 'initial_values'
      end

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

      errors
    end
  end
end




