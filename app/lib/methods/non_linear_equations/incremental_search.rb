module Methods::NonLinearEquations::IncrementalSearch 
  class << self
    def exec(func, x0, delta, nmax = 100)
      @func = Methods::Utils::Commons.format_function(func)
      @x0 = x0
      @delta = delta
      @nmax = nmax

      @iterations = []
      @errors = []

      initial_validations()

      return { iterations: [], errors: @errors } unless @errors.empty?

      f = ->(x) { eval(@func) }
      _Fx0 = f.call(@x0)
      x0 = @x0

      if _Fx0 == 0
        return { iterations: [], errors: }
      end

      (1..@nmax).each do |i|
        x1 = x0 + @delta

        begin
          _Fx1 = f.call(x1)
        rescue
          ap "Error al evaluar f(x1): #{e.message}"
        end

        if _Fx0 * _Fx1 <= 0
          @iterations << { x0:, x1: }
        end

        x0 = x1
        _Fx0 = _Fx1
      end

      if @iterations.empty?
        @errors << 'not_found'
      end

      return { iterations: @iterations, errors: @errors }
    end

    private

    def initial_validations
      @errors = Methods::Utils::Validations.delta @delta, @errors
      @errors = Methods::Utils::Validations.max_iterations @nmax, @errors
      @errors = Methods::Utils::Validations.numeric_value @x0, 'x0', @errors

      return unless @errors.empty?

      @errors = Methods::Utils::Validations.function @func, nil, { x0: @x0 }, @errors
    end
  end
end
