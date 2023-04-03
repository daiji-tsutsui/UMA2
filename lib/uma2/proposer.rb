# frozen_string_literal: true

require 'uma2/optimizer/model'

module Uma2
  # Proposer for optimized strategy
  class Proposer
    attr_reader :t

    def initialize(params, odds, option: nil)
      @settings = Settings.uma2.proposer
      @b, @t = extract(params)
      @odds = odds
      @bet = @settings.default_bet
      @min_hit = @settings.hit_probability_min
      customize_params!(option) if option.present?
    end

    def gain_strategy
      @gain_strategy ||= build_gain_strategy
    end

    def hit_strategy
      @hit_strategy ||= build_hit_strategy
    end

    def base_strategy
      @base_strategy ||= build_base_strategy
    end

    private

    def extract(params)
      b = params['b'] || params[:b]
      t = params['t'] || params[:t]
      [b[-1], Probability.new(t)]
    end

    def customize_params!(params)
      @bet     = params[:bet].to_i         if params[:bet].present?
      @b       = params[:certainty].to_f   if params[:certainty].present?
      @min_hit = params[:minimum_hit].to_f if params[:minimum_hit].present?
    end

    def build_base_strategy
      model_strategy = Optimizer::Model.new.strategy(@odds, @b, @t)
      Distribution.new(model_strategy, @t, @odds)
    end

    def build_gain_strategy
      discrete_base_strategy(@bet)
    end

    def build_hit_strategy
      strategy = strategy_from(Array.new(@odds.size, 0))
      hit_probability = 0.0
      t_order.size.times do |i|
        break if hit_probability >= @min_hit

        index = t_order[i]
        strategy[index] += 1
        hit_probability += @t[index]
      end
      strategy + discrete_base_strategy(@bet - strategy.sum)
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

    def t_order
      size = @t.size - 1
      (0..size).sort { |i, j| @t[j] <=> @t[i] }
    end

    def strategy_from(array)
      Strategy.new(array, @t, @odds)
    end
  end
end
