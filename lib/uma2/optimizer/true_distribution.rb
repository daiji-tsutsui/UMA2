# frozen_string_literal: true

module Uma2
  class Optimizer
    # True distribution parameter for odds forecasting model
    class TrueDistribution < Uma2::Probability
      def update(odds_list, model, a, b)
        @eps = Settings.uma2.learning_rate
        @model_p = model.series
        @strategies = model.strategies
        @odds_list = odds_list
        @a = a
        @b = b
        v = grad.map { |dt_i| -@eps * dt_i }
        move_with_natural_grad!(v)
      end

      private

      def grad
        (1..size - 1).map { |j| grad_entry(j) }
      end

      # odds_list: 0 1 2 ... n-1 n
      # model_p:   0 1 2 ... n-1
      # index m:     1 2 ... n-1 n
      def grad_entry(j)
        @model_p.map.with_index(1) do |p, m|
          grad_at_instant(j, m, p)
        end.sum
      end

      def grad_at_instant(j, m, p)
        a = @a.shrink(m)
        q = Probability.new_from_odds(@odds_list[m])
        (1..m).map do |k|
          f = grad_at_instant_integrant(j, k, p)
          - a[k] * @b[k] * q.expectation(f)
        end.sum
      end

      def grad_at_instant_integrant(j, k, p)
        strategy = @strategies[k - 1]
        odds = @odds_list[k]
        p.map.with_index do |p_i, i|
          strategy[i] * (part(strategy, odds, i, j) - part(strategy, odds, i, 0)) / p_i
        end
      end

      def part(strategy, odds, i, j)
        (delta(i, j) - strategy[j]) * odds[j]
      end

      def delta(i, j)
        Probability.delta(i, j)
      end
    end
  end
end
