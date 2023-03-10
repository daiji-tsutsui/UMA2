# frozen_string_literal: true

module Uma2
  class Optimizer
    # Certainty parameter for odds forecasting model
    class Certainty < Uma2::Positives
      def update(odds_list, model, a, t)
        @eps = DEFAULT_LEARNING_RATE
        @model_p = model.series
        @strategies = model.strategies
        @odds_list = odds_list
        @a = a
        @t = t
        v = grad.map { |db_i| -@eps * db_i }
        move_with_natural_grad!(v)
      end

      private

      def grad
        (1..@strategies.size).map { |k| grad_entry(k) }
      end

      def grad_entry(k)
        @model_p.map.with_index(1) do |p, m|
          grad_at_instant(k, m, p)
        end.sum
      end

      def grad_at_instant(k, m, p)
        return 0.0 if k > m

        sub_f = @t.schur(@odds_list[k])
        f = grad_at_instant_integrant(k, m, p, sub_f)
        q = Probability.new_from_odds(@odds_list[m])
        -q.expectation(f)
      end

      def grad_at_instant_integrant(k, m, p, f1)
        strategy = @strategies[k - 1]
        a = @a.shrink(m)
        exp_f1 = strategy.expectation(f1)
        p.map.with_index do |p_i, i|
          a[k] * strategy[i] * (f1[i] - exp_f1) / p_i
        end
      end
    end
  end
end
