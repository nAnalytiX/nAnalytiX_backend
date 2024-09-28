module Methods::Secant
  class << self
    def exec(func, x0, x1, tol, nmax, error_type = 'abs')
      @tol = tol
      @nmax = nmax
      @func = Methods::Commons.format_function(func)

      errors = initial_validations(x0, x1)

      return { data: [], errors: } unless errors.empty?

      x0 = x0.to_f
      x1 = x1.to_f
      f = ->(x) { eval(@func) }
      conclution = nil
      error = Float::INFINITY

      iterations = [
        { i: 0, x: x0, fx: f.call(x0), error: },
        { i: 1, x: x1, fx: f.call(x1), error: },
      ]

      (2..nmax).each do |i|
        _Fx0 = f.call(x0)
        _Fx1 = f.call(x1)

        if _Fx1 - _Fx0 == 0
          errors << 'divide_by_zero'

          break
        end

        x_new = x1 - _Fx1 * (x1 - x0) / (_Fx1 - _Fx0)

        if i > 1
          # error = ((x_new - x1).abs / x_new.abs).abs
          error = Methods::Commons.calc_error(x_new, x1, error_type)
        end

        iterations << { i:, x: x_new, fx: _Fx1, error: }

        if error < tol || x_new == 0
          break
        end

        x0 = x1
        x1 = x_new
      end

      final_validations(iterations, errors)
    end

    private

    def initial_validations(x0, x1)
      errors = []

      if @tol <= 0
        errors << 'tol'
      end

      if @nmax <= 0
        errors << 'nmax'
      end

      if x0.is_a? Numeric
        x0 = x0.to_f
      else
        errors << 'x0'
      end

      if x1.is_a? Numeric
        x1 = x1.to_f
      else
        errors << 'x1'
      end

      return errors unless errors.empty?

      if x0 == x1
        errors << 'initial_values'
      end

      begin
        f = ->(x) { eval(@func) }
      rescue StandardError
        errors << 'function_eval'
      end

      f.call(x0) rescue errors << 'function_eval_x0'

      errors
    end

    def final_validations iterations, errors
      conclution = nil
      last_iteration = iterations.last

      if !errors.empty?
        errors
      elsif last_iteration[:fx] == 0
        conclution = { message: 'root_found', value: last_iteration[:x], iteration: last_iteration[:i] }
      elsif last_iteration[:error] < @tol
        conclution = { message: 'root_aproximation', value: last_iteration[:x], iteration: last_iteration[:i] }
      elsif last_iteration[:i] === @nmax
        errors << 'root_not_found'
      else
        errors << 'method_failure'
      end

      { iterations:, conclution:, errors: }
    end
  end
end
