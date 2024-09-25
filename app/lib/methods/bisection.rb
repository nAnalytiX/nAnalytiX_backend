module Methods::Bisection
  class << self
    def exec(func, a, b, tol, nmax)
      errors = intial_validations(func, a, b, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }
      _Fx_b = f.call(a)
      _Fx_a = f.call(b)

      iterations = []

      error = Float::INFINITY
      m_old = (a + b) / 2.0

      (1..nmax).each do |i|
        m_new = (a + b) / 2.0
        _Fx_m = f.call(m_new)

        if i > 1
          error = ((m_new - m_old).abs / m_new.abs).abs
        end

        iterations << { i:, a:, m: m_new, b:, fa: _Fx_b, fm: _Fx_m, fb: _Fx_a, error: }

        if error < tol || _Fx_m == 0
          break
        end

        if _Fx_b * _Fx_m < 0
          b = m_new
          _Fx_a = _Fx_m
        else
          a = m_new
          _Fx_b = _Fx_m
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

      begin
        f = ->(x) { eval(func) }
      rescue StandardError
        errors << 'function_eval'
      end

      fa = f.call(a)
      fb = f.call(b)
      
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

