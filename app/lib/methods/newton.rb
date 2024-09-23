module Methods::Newton
  class << self
    def exec(func, derivate, x0, tol, nmax)
      errors = validations(func, derivate, x0, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }
      f_prime = ->(x) { eval(derivate) }

      conclution = nil
      iterations = []

      x_old = x0
      error = Float::INFINITY

      (1..nmax).each do |i|
        f_x = f.call(x_old)
        f_prime_x = f_prime.call(x_old)

        if f_prime_x == 0
          errors << 'derivate_zero'

          break
        end

        x_new = x_old - f_x / f_prime_x

        if i > 1
          error = ((x_new - x_old).abs / x_new.abs).abs
        end

        iterations << { i:, x: x_new, f_prime: f_prime_x, fx: f_x, error: }

        if x_new == 0
          conclution = { iteration: i, value: x_new, found: true }

          break
        end

        if error < tol
          conclution = { iteration: i, value: x_new, found: false }

          break
        end

        x_old = x_new
      end

      errors << 'not_found' if conclution.nil?

      return { conclution:, iterations:, errors: }
    end

    private

    def validations(func, derivate, x0, tol, nmax)
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

      begin
        f = ->(x) { eval(derivate) }
      rescue StandardError
        errors << 'derivate_eval'
      end

      errors
    end
  end
end




