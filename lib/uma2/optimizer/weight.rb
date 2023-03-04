# frozen_string_literal: true

module Uma2
  class Optimizer
    # Weight parameter for odds forecasting model
    class Weight < Uma2::Probability
      def update(odds_list, model)
        @eps = DEFAULT_LEARNING_RATE
        @model_p = model.series
        @strategies = model.strategies
        @odds_list = odds_list
        @ini_p = Probability.new_from_odds(@odds_list[0])
        v = grad.map { |da_i| -@eps * da_i }
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
        f = grad_at_instant_integrant(k, m, p)
        q = Probability.new_from_odds(@odds_list[m])
        -q.expectation(f)
      end

      def grad_at_instant_integrant(k, m, p)
        if k > m
          grad_integrant_for_small_m(k, m, p)
        else
          grad_integrant_for_large_m(k, m, p)
        end
      end

      def grad_integrant_for_small_m(_k, m, p)
        alpha = shrink_rate(m)
        p.map.with_index do |p_i, i|
          shrink(m).map.with_index(1) do |a_h, h|
            alpha * a_h * (@strategies[h - 1][i] - @ini_p[i]) / p_i
          end.sum
        end
      end

      def grad_integrant_for_large_m(k, m, p)
        alpha = shrink_rate(m)
        p.map.with_index do |p_i, i|
          alpha * (@strategies[k - 1][i] - @ini_p[i]) / p_i
        end
      end
    end
  end
end
