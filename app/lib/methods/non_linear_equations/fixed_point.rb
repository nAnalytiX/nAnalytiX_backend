module Methods::NonLinearEquations
  class FixedPoint

    def initialize(func_x, func_g, x0, tol = 0.0000001, nmax = 100, error_type = 'abs')
      @func_x = Methods::Utils::Commons.format_function(func_x)
      @func_g = Methods::Utils::Commons.format_function(func_g)
      @x0 = x0
      @tol = tol
      @nmax = nmax
      @error_type = error_type

      @conclution = nil
      @iterations = []
      @errors = []
    end

    def exec
      initial_validations()

      return { conclution: nil, iterations: [], errors: @errors } unless @errors.empty?

      f = ->(x) { eval(@func_x) }
      g = ->(x) { eval(@func_g) }

      x_old = @x0.to_f
      error = Float::INFINITY

      @iterations = [{ i: 0, x: x_old, fx: f.call(x_old), gx: g.call(x_old), error: }]

      (1..@nmax).each do |i|
        x_new = g.call(x_old)
        fx = f.call(x_new)

        #error = ((x_new - x_old).abs / x_new.abs).abs
        error = Methods::Utils::Commons.calc_error(x_new, x_old, @error_type)

        @iterations << { i:, x: x_new, fx: fx, gx: x_old, error: }

        if fx == 0 || error < @tol
          break
        end

        x_old = x_new
      end

      final_validations()

      { conclution: @conclution, iterations: @iterations, errors: @errors }
    end

    private

    def initial_validations
      if @func_x == @func_g 
        @errors << 'same_func'

        return
      end

      @errors = Methods::Utils::Validations.tolerance @tol, @errors
      @errors = Methods::Utils::Validations.max_iterations @nmax, @errors
      @errors = Methods::Utils::Validations.numeric_value @x0, 'x0_value', @errors

      return unless @errors.empty?

      @errors = Methods::Utils::Validations.function @func_x, 'function_f', { x0: @x0 }, @errors
      @errors = Methods::Utils::Validations.function @func_g, 'function_g', { x0: @x0 }, @errors
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
