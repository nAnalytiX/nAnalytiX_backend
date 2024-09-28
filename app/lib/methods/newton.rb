module Methods
  class Newton
    def initialize(func, derivate, x0, tol, nmax, error_type = 'abs')
      @func = Methods::Commons.format_function(func)
      @derivate = Methods::Commons.format_function(derivate)
      @x0 = x0
      @tol = tol || 0.0000001
      @nmax = nmax || 100
      @error_type = error_type

      @iterations = []
      @errors = []
    end

    def exec
      initial_validations()

      return { conclution: nil, iterations: [], errors: @errors } unless @errors.empty?

      x0 = @x0.to_f
      f = ->(x) { eval(@func) }
      f_prime = ->(x) { eval(@derivate) }

      conclution = nil

      x_old = x0
      error = Float::INFINITY

      @iterations << { i: 0, x: x0, fx: f.call(x_old), f_prime: f_prime.call(x_old), error: }

      (1..@nmax).each do |i|
        _Fx = f.call(x_old)
        _Fprime_x = f_prime.call(x_old)

        if _Fprime_x == 0
          @errors << 'derivate_zero'

          break
        end

        x_new = x_old - _Fx / _Fprime_x

        if i > 1
          # error = ((x_new - x_old).abs / x_new.abs).abs
          error = Methods::Commons.calc_error(x_new, x_old, @error_type)
        end

        @iterations << { i:, x: x_new, fx: _Fx, f_prime: _Fprime_x, error: }

        if error < @tol || x_new == 0
          break
        end

        x_old = x_new
      end

      conclution = final_validations()

      { conclution: , iterations: @iterations, errors: @errors }
    end

    private

    def initial_validations
      @errors = Methods::Validations.tolerance @tol, @errors

      @errors = Methods::Validations.max_iterations @nmax, @errors

      @errors = Methods::Validations.x0_value @x0, @errors

      return unless @errors.empty?

      @errors = Methods::Validations.function @func, nil, { x0: @x0 }, @errors
      @errors = Methods::Validations.function @derivate, 'derivate', { x0: @x0 }, @errors
    end

    def final_validations
      conclution = nil
      last_iteration = @iterations.last

      return conclution unless @errors.empty?

      if last_iteration[:fx] == 0
        conclution = { message: 'root_found', value: last_iteration[:x], iteration: last_iteration[:i] }
      elsif last_iteration[:error] < @tol
        conclution = { message: 'root_aproximation', value: last_iteration[:x], iteration: last_iteration[:i] }
      elsif last_iteration[:i] === @nmax
        @errors << 'root_not_found'
      else
        @errors << 'method_failure'
      end

      conclution
    end
  end
end
