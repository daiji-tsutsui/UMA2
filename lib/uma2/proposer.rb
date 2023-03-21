# frozen_string_literal: true

require 'uma2/optimizer/model'

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
      return @gain_strategy unless @gain_strategy.nil?

      @gain_strategy = discrete_base_strategy(@bet)
    end

    def gain_expectation
      expectation(gain_strategy)
    end

    def gain_probability
      probability(gain_strategy)
    end

    def hit_strategy
      return @hit_strategy unless @hit_strategy.nil?

      @hit_strategy = build_hit_strategy
    end

    def hit_expectation
      expectation(hit_strategy)
    end

    def hit_probability
      probability(hit_strategy)
    end

    def base_strategy
      return @base_strategy unless @base_strategy.nil?

      @base_strategy = Optimizer::Model.new.strategy(@odds, @b, @t)
    end

    def base_expectation
      expectation(base_strategy)
    end

    private

    def extract(params)
      b = params['b'] || params[:b]
      t = params['t'] || params[:t]
      [b, t]
    end

    def build_hit_strategy
      strategy = Array.new(@odds.size, 0)
      hit_probability = 0.0
      @odds.size.times do |i|
        break if hit_probability >= @settings.hit_probability_min

        weight, index = @t.each.with_index.sort.reverse[i]
        strategy[index] = 1
        hit_probability += weight
      end
      sub_strategy = discrete_base_strategy(@bet - strategy.sum)
      strategy.map.with_index { |s_i, i| s_i + sub_strategy[i] }
    end

    def discrete_base_strategy(bet)
      strategy = base_strategy.map { |w| (w * bet).floor }
      strategy.size.times do |i|
        break if strategy.sum >= bet

        _weight, index = base_strategy.each.with_index.sort.reverse[i]
        strategy[index] += 1
      end
      strategy
    end

    def expectation(strategy)
      f = strategy.map.with_index { |s_i, i| s_i * @odds[i] }
      @t.expectation(f)
    end

    def probability(strategy)
      @t.map.with_index { |p_i, i| strategy[i].zero? ? 0.0 : p_i }.sum
    end
  end
end
