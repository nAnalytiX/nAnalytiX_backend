module Methods::MultipleRoots
  class << self
    def exec(func, first_derivate, second_derivate, x0, tol = 0.0000001, nmax = 100)
      errors = validations(func, first_derivate, second_derivate, x0, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }
      f_prime = ->(x) { eval(first_derivate) }
      f_double_prime = ->(x) { eval(second_derivate) }

      conclution = nil
      iterations = []

      error = Float::INFINITY

      (1..nmax).each do |i|
        f_x = f.call(x0)
        f_prime_x = f_prime.call(x0)
        f_double_prime_x = f_double_prime.call(x0)

        if f_prime_x == 0
          errors << 'derivate_zero'

          break
        end

        x_new = x0 - f_x * f_prime_x / (f_prime_x ** 2 - f_x * f_double_prime_x)

        if i > 1
          error = ((x_new - x0).abs / x_new.abs).abs
        end

        iterations << { i:, x: x_new, fx: f_x, f_prime: f_prime_x, f_double_prime: f_double_prime_x , error: }

        if x_new == 0
          conclution = { iteration: i, value: x_new, found: true }

          break
        end

        if error < tol
          conclution = { iteration: i, value: x_new, found: false }

          break
        end

        x0 = x_new
      end

      errors << 'not_found' if conclution.nil?

      return { conclution:, iterations:, errors: }
    end

    private

    def validations(func, first_derivate, second_derivate, x0, tol, nmax)
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
        f = ->(x) { eval(first_derivate) }
      rescue StandardError
        errors << 'first_derivate_eval'
      end

      begin
        f = ->(x) { eval(second_derivate) }
      rescue StandardError
        errors << 'second_derivate_eval'
      end

      errors
    end
  end
end




