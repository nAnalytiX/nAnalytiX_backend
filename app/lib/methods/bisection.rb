module Methods::Bisection
  class << self
    def exec(func, a, b, tol, nmax)
      errors = validations(func, a, b, tol, nmax)

      return { data: [], errors: } unless errors.empty?

      f = ->(x) { eval(func) }
      fa = f.call(a)
      fb = f.call(b)

      conclution = nil
      iterations = []

      error = Float::INFINITY
      m_old = (a + b) / 2.0

      (1..nmax).each do |i|
        m_new = (a + b) / 2.0
        fm = f.call(m_new)
        

        if i > 1
          error = ((m_new - m_old).abs / m_new.abs).abs
        end

        iterations << { i:, a:, m: m_new, b:, fa:, fm:, fb:, error: }

        if error < tol
          conclution = { iteration: i, value: m_new }

          break
        end

        if fa * fm < 0
          b = m_new
          fb = fm
        else
          a = m_new
          fa = fm
        end

        m_old = m_new
      end

      errors << 'not_found' if conclution.nil?

      return { conclution:, iterations:, errors: }
    end

    private

    def validations(func, a, b, tol, nmax)
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
  end
end

