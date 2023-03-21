# frozen_string_literal: true

require 'uma2/optimizer/model'
require 'uma2/proposer/strategy'

module Uma2
  # Proposer for optimized strategy
  class Proposer
    attr_reader :t

    def initialize(params, odds, bet)
      raise 'Only integer bet is permitted' unless bet.is_a?(Integer)

      b, t = extract(params)
      @b = b[-1]
      @t = Probability.new(t)
      @odds = odds
      @bet = bet
      @settings = Settings.uma2.proposer
    end

    def gain_strategy
      @gain_strategy ||= discrete_base_strategy(@bet)
    end

    def hit_strategy
      @hit_strategy ||= build_hit_strategy
    end

    def base_strategy
      @base_strategy ||= Optimizer::Model.new.strategy(@odds, @b, @t)
    end

    def base_expectation
      @t.expectation(base_strategy)
    end

    private

    def extract(params)
      b = params['b'] || params[:b]
      t = params['t'] || params[:t]
      [b, t]
    end

    def discrete_base_strategy(bet)
      strategy = strategy_from(base_strategy.map { |w| w * bet })
      strategy.redistribute!(bet, base_strategy_order)
      strategy
    end

    def base_strategy_order
      size = base_strategy.size - 1
      (0..size).sort { |i, j| base_strategy[j] <=> base_strategy[i] }
    end

    def build_hit_strategy
      strategy = strategy_from(Array.new(@odds.size, 0))
      hit_probability = 0.0
      t_order.size.times do |i|
        break if hit_probability >= @settings.hit_probability_min

        index = t_order[i]
        strategy[index] += 1
        hit_probability += @t[index]
      end
      strategy + discrete_base_strategy(@bet - strategy.sum)
    end

    def t_order
      size = @t.size - 1
      (0..size).sort { |i, j| @t[j] <=> @t[i] }
    end

    def strategy_from(array)
      Strategy.new(array, @t, @odds)
    end
  end
end
