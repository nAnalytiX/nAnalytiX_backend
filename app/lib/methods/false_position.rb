module Methods::FalsePosition
  class << self
    def exec(func, a, b, tol, nmax, error_type = 'abs')
      func = Methods::Commons.format_function(func)

      errors = intial_validations(func, a, b, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }
      a = a.to_f
      b = b.to_f
      _Fx_a = f.call(a)
      _Fx_b = f.call(b)

      conclution = nil
      iterations = []

      error = Float::INFINITY
      m_old = b

      (1..nmax).each do |i|
        m_new = b - ((_Fx_b * (b - a)) / (_Fx_b - _Fx_a))
        _Fx_m = f.call(m_new)

        if i > 1
          #error = ((m - m_old).abs / m.abs).abs
          error = Methods::Commons.calc_error(m_new, m_old, error_type)
        end

        iterations << { i:, a:, m: m_new, b:, fa: _Fx_a, fm: _Fx_m, fb: _Fx_b, error: }

        if error < tol || _Fx_m == 0
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

      final_validations(iterations, tol, nmax, errors)
    end

    private

    def intial_validations(func, a, b, tol, nmax)
      errors = []

      if tol <= 0
        errors << 'tol'
      end

      if nmax <= 0
        errors << 'nmax'
      end

      if a.is_a? Numeric
        a = a.to_f
      else
        errors << 'a_interval'
      end

      if b.is_a? Numeric
        b = b.to_f
      else
        errors << 'b_interval'
      end

      return errors unless errors.empty?

      begin
        f = ->(x) { eval(func) }
      rescue StandardError
        errors << 'function_eval'
      end

      fa = f.call(a) rescue errors << 'function_eval_a'
      fb = f.call(b) rescue errors << 'function_eval_b'
      
      if fa * fb > 0
        errors << 'interval'
      end

      errors
    end

    def final_validations iterations, tol, nmax, errors
      conclution = nil
      last_iteration = iterations.last

      if last_iteration[:fm] == 0
        conclution = { message: 'root_found', value: last_iteration[:m], iteration: last_iteration[:i] }
      elsif last_iteration[:error] < tol
        conclution = { message: 'root_aproximation', value: last_iteration[:m], iteration: last_iteration[:i] }
      elsif last_iteration[:i] === nmax
        errors << 'root_not_found'
      else
        errors << 'method_failure'
      end

      { iterations:, conclution:, errors: }
    end

  end
end


