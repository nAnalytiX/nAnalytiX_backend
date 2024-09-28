module Methods
  class Bisection
    def initialize(func, a, b, tol, nmax, error_type = 'abs')
      @func = Methods::Commons.format_function(func)
      @a = a
      @b = b
      @tol = tol || 0.0000001
      @nmax = nmax || 100
      @error_type = error_type

      @iterations = []
      @errors = []
    end

    def exec
      intial_validations()

      return { conclution: nil, iterations: [], errors: @errors } unless @errors.empty?

      a = @a.to_f
      b = @b.to_f
      f = ->(x) { eval(@func) }
      _Fx_a = f.call(a)
      _Fx_b = f.call(b)

      if _Fx_a * _Fx_b > 0
        return { conclution: nil, iterations: [], errors: ['interval'] }
      end

      error = Float::INFINITY
      m_old = (a + b) / 2.0

      (1..@nmax).each do |i|
        m_new = (a + b) / 2.0
        _Fx_m = f.call(m_new)

        if i > 1
          #error = ((m_new - m_old).abs / m_new.abs).abs
          error = Methods::Commons.calc_error(m_new, m_old, @error_type)
        end

        @iterations << { i:, a:, m: m_new, b:, fa: _Fx_b, fm: _Fx_m, fb: _Fx_a, error: }

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

      conclution = final_validations()

      { conclution: , iterations: @iterations, errors: @errors }
    end

    private

    def intial_validations
      @errors = Methods::Validations.tolerance @tol, @errors

      @errors = Methods::Validations.max_iterations @nmax, @errors

      @errors = Methods::Validations.a_interval @a, @errors

      @errors = Methods::Validations.b_interval @a, @errors

      return unless @errors.empty?

      @errors = Methods::Validations.function @func, nil, { a: @a, b: @b }, @errors
    end

    def final_validations
      conclution = nil
      last_iteration = @iterations.last

      if last_iteration[:fm] == 0
        conclution = { message: 'root_found', value: last_iteration[:m], iteration: last_iteration[:i] }
      elsif last_iteration[:error] < @tol
        conclution = { message: 'root_aproximation', value: last_iteration[:m], iteration: last_iteration[:i] }
      elsif last_iteration[:i] === @nmax
        @errors << 'root_not_found'
      else
        @errors << 'method_failure'
      end

      conclution
    end

  end
end

