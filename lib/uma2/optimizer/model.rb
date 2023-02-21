# frozen_string_literal: true

# require 'uma2/optimizer/weight'
# require 'uma2/optimizer/certainty'
# require 'uma2/optimizer/true_distribution'

module Uma2
  class Optimizer
    # Odds forecasting model
    class Model
      attr_reader :series, :strategies

      def initialize
        @series = []
        @strategies = []
      end

      def forecast(odds_list, params)
        p = Probability.new_from_odds(@odds_list[0])
        @series = (1..odds_list.size - 1).map do |i|
          odds = odds_list[i - 1]
          a = params[:a][i] * params[:a].shrink_rate(i)
          b = params[:b][i]
          p = forecast_next(p, odds, a, b, params[:t])
        end
      end

      def forecast_next(prev, odds, a, b, t)
        s = strategy(odds, b, t)
        @strategies.push s
        w = prev.map.with_index { |r, i| ((1.0 - a) * r) + (a * s[i]) }
        Probability.new(w)
      end

      def strategy(odds, b, t)
        expect_gain = t.schur(odds)
        w = expect_gain.map { |r| Math.exp(r * b) }
        Probability.new(w)
      end

      def loss(odds_list)
        return 0.0 if @series.empty?

        @series.map.with_index do |p, k|
          q = Probability.new_from_odds(odds_list[k + 1])
          q.kl_div(p)
        end.sum
      end
    end
  end
end
