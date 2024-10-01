module Methods::NonLinearEquations::Secant
  class << self
    def exec(func, x0, x1, tol = 0.0000001, nmax = 100, error_type = 'abs')
      @func = Methods::Utils::Commons.format_function(func)
      @x0 = x0
      @x1 = x1
      @tol = tol
      @nmax = nmax
      @error_type = error_type

      @conclution = nil
      @iterations = []
      @errors = []

      initial_validations()

      return { conclution: nil, iterations: [], errors: @errors } unless @errors.empty?

      x0 = @x0.to_f
      x1 = @x1.to_f
      f = ->(x) { eval(@func) }
      error = Float::INFINITY

      @iterations = [
        { i: 0, x: x0, fx: f.call(x0), error: },
        { i: 1, x: x1, fx: f.call(x1), error: },
      ]

      (2..@nmax).each do |i|
        _Fx0 = f.call(x0)
        _Fx1 = f.call(x1)

        if _Fx1 - _Fx0 == 0
          @errors << 'divide_by_zero'

          break
        end

        x_new = x1 - _Fx1 * (x1 - x0) / (_Fx1 - _Fx0)

        error = Methods::Utils::Commons.calc_error(x_new, x1, @error_type)
        # error = ((x_new - x1).abs / x_new.abs).abs

        @iterations << { i:, x: x_new, fx: _Fx1, error: }

        if error < @tol || x_new == 0
          break
        end

        x0 = x1
        x1 = x_new
      end

      final_validations()

      { conclution: @conclution, iterations: @iterations, errors: @errors }
    end

    private

    def initial_validations
      @errors = Methods::Utils::Validations.tolerance @tol, @errors
      @errors = Methods::Utils::Validations.max_iterations @nmax, @errors

      @errors = Methods::Utils::Validations.numeric_value @x0, 'x0_value', @errors
      @errors = Methods::Utils::Validations.numeric_value @x1, 'x1_value', @errors

      return unless @errors.empty?

      if @x0 == @x1
        @errors << 'initial_values'

        return
      end

      @errors = Methods::Utils::Validations.function @func, nil, { x0: @x0, x1: @x1 }, @errors
    end

    def final_validations
      return @conclution unless @errors.empty?

      last_iteration = @iterations.last

      if last_iteration[:fx] == 0
        @conclution = { message: 'root_found', value: last_iteration[:x], iteration: last_iteration[:i] }
      elsif last_iteration[:error] < @tol
        @conclution = { message: 'root_aproximation', value: last_iteration[:x], iteration: last_iteration[:i] }
      elsif last_iteration[:i] === @nmax
        @errors << 'root_not_found'
      else
        @errors << 'method_failure'
      end
    end
  end
end
