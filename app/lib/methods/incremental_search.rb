module Methods
  class IncrementalSearch 
    def initialize(func, x0, delta, nmax = 100)
      @func = Methods::Commons.format_function(func)
      @x0 = x0
      @delta = delta
      @nmax = nmax
      @errors = []
    end

    def exec
      initial_validations

      return { data: [], errors: @errors } unless @errors.empty?

      f = ->(x) { eval(@func) }
      _Fx0 = f.call(@x0)
      x0 = @x0

      if _Fx0 == 0
        return { data: [], errors: }
      end

      data = []

      byebug

      (1..@nmax).each do |i|
        x1 = x0 + @delta

        begin
          _Fx1 = f.call(x1)
        rescue
          ap "Error al evaluar f(x1): #{e.message}"
        end

        if _Fx0 * _Fx1 <= 0
          data << { x0:, x1: }
        end

        x0 = x1
        _Fx0 = _Fx1
      end

      if data.empty?
        @errors << 'not_found'
      end

      return { data:, errors: @errors }
    end

    private

    def initial_validations
      if @delta == 0
        @errors << 'delta'
      end

      if @nmax <= 0
        @errors << 'nmax'
      end

      if @x0.is_a? Numeric
        x0 = @x0.to_f
      else
        @errors << 'x0'
      end

      return unless @errors.empty?

      begin
        f = ->(x) { eval(@func) }
      rescue
        @errors << 'function_eval'
      end

      f.call(x0) rescue @errors << 'function_eval_x0'
    end
  end
end
