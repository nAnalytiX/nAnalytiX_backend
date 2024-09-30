module Methods
  class MultipleRoots
    def initialize(func, first_derivate, second_derivate, x0, tol = 0.0000001, nmax = 100, error_type = 'abs')
      @func = Methods::Commons.format_function(func)
      @first_derivate = Methods::Commons.format_function(first_derivate)
      @second_derivate = Methods::Commons.format_function(second_derivate)
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

      x0 = @x0
      f = ->(x) { eval(@func) }
      f_prime = ->(x) { eval(@first_derivate) }
      f_double_prime = ->(x) { eval(@second_derivate) }

      error = Float::INFINITY

      @iterations = [{ i: 0, x: x0, fx: f.call(x0), error: }]

      (1..@nmax).each do |i|
        f_x = f.call(x0)
        f_prime_x = f_prime.call(x0)
        f_double_prime_x = f_double_prime.call(x0)

        if f_prime_x == 0
          @errors << 'derivate_zero'

          break
        end

        x_new = x0 - f_x * f_prime_x / (f_prime_x ** 2 - f_x * f_double_prime_x)

        error = ((x_new - x0).abs / x_new.abs).abs

        @iterations << { i:, x: x_new, fx: f_x, error: }

        if x_new == 0 || error < @tol
          break
        end

        x0 = x_new
      end

      final_validations()

      { conclution: @conclution, iterations: @iterations, errors: @errors }
    end

    private

    def initial_validations
      @errors = Methods::Validations.tolerance @tol, @errors
      @errors = Methods::Validations.max_iterations @nmax, @errors
      @errors = Methods::Validations.numeric_value @x0, 'x0_value', @errors

      return unless @errors.empty?

      @errors = Methods::Validations.function @func, nil, { x0: @x0 }, @errors
      @errors = Methods::Validations.function @first_derivate, 'first_derivate', { x0: @x0 }, @errors
      @errors = Methods::Validations.function @second_derivate, 'second_derivate', { x0: @x0 }, @errors
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
