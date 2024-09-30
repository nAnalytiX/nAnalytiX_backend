module Methods
  class FalsePosition
    def initialize(func, a, b, tol = 0.0000001, nmax = 100, error_type = 'abs')
      @func = Methods::Commons.format_function(func)
      @a = a
      @b = b
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

      f = ->(x) { eval(@func) }
      a = @a.to_f
      b = @b.to_f
      _Fx_a = f.call(a)
      _Fx_b = f.call(b)

      error = Float::INFINITY
      m_old = b

      (1..@nmax).each do |i|
        m_new = b - ((_Fx_b * (b - a)) / (_Fx_b - _Fx_a))
        _Fx_m = f.call(m_new)

        if i > 1
          #error = ((m - m_old).abs / m.abs).abs
          error = Methods::Commons.calc_error(m_new, m_old, @error_type)
        end

        @iterations << { i:, a:, m: m_new, b:, fa: _Fx_a, fm: _Fx_m, fb: _Fx_b, error: }

        if error < @tol || _Fx_m == 0
          break
        end

        if _Fx_a * _Fx_m < 0
          b = m_new
          _Fx_b = _Fx_m
        else
          a = m_new
          _Fx_a = _Fx_m
        end

        m_old = m_new
      end

      final_validations()

      { conclution: @conclution, iterations: @iterations, errors: @errors }
    end

    private

    def initial_validations
      @errors = Methods::Validations.tolerance @tol, @errors
      @errors = Methods::Validations.max_iterations @nmax, @errors
      @errors = Methods::Validations.numeric_value @a, 'a_interval', @errors
      @errors = Methods::Validations.numeric_value @b, 'b_interval', @errors

      return unless @errors.empty?

      @errors = Methods::Validations.function @func, nil, { a: @a, b: @b }, @errors

      f = ->(x) { eval(@func) }

      if f.call(@a) * f.call(@b) > 0
        @errors << 'interval'
      end
    end

    def final_validations
      return @conclution unless @errors.empty?

      last_iteration = @iterations.last

      if last_iteration[:fm] == 0
        @conclution = { message: 'root_found', value: last_iteration[:m], iteration: last_iteration[:i] }
      elsif last_iteration[:error] < @tol
        @conclution = { message: 'root_aproximation', value: last_iteration[:m], iteration: last_iteration[:i] }
      elsif last_iteration[:i] === @nmax
        @errors << 'root_not_found'
      else
        @errors << 'method_failure'
      end
    end

  end
end
