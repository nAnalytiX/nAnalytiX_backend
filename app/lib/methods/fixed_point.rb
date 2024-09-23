module Methods::FixedPoint
  class << self
    def exec(func_x, func_g, x0, tol, nmax)
      errors = validations(func_x, func_g, x0, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func_x) }
      g = ->(x) { eval(func_g) }

      conclution = nil
      iterations = []

      x_old = x0
      error = Float::INFINITY

      (1..nmax).each do |i|
        x_new = g.call(x_old)

        if i > 1
          error = ((x_new - x_old).abs / x_new.abs).abs
        end

        iterations << { i:, x: x_new, gx: x_old, fx: f.call(x_new), error: }

        if error < tol
          conclution = { iteration: i, value: x_new }

          break
        end

        x_old = x_new
      end

      errors << 'not_found' if conclution.nil?

      return { conclution:, iterations:, errors: }
    end

    private

    def validations(func_x, func_g, x0, tol, nmax)
      errors = []

      if func_x == func_g 
        errors << 'same_func'

        return errors
      end

      if tol <= 0
        errors << 'tol'
      end

      if nmax <= 0
        errors << 'nmax'
      end

      begin
        f = ->(x) { eval(func_x) }
      rescue StandardError
        errors << 'function_x_eval'
      end

      begin
        f = ->(x) { eval(func_g) }
      rescue StandardError
        errors << 'function_g_eval'
      end

      errors
    end
  end
end



