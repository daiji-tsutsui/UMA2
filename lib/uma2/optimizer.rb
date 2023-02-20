# frozen_string_literal: true

require 'uma2/optimizer/weight'
require 'uma2/optimizer/certainty'
require 'uma2/optimizer/true_distribution'

module Uma2
  # Optimizer of odds forecasting model
  class Optimizer
    def initialize(params: {})
      if params.has_key?('a')
        @a = Weight.new(params['a'])
        @b = Certainty.new(params['b'])
        @t = TrueDistribution.new(params['t'])
      else
        @a = Weight.new(params[:a])
        @b = Certainty.new(params[:b])
        @t = TrueDistribution.new(params[:t])
      end
    end

    def params
      {
        a: @a,
        b: @b,
        t: @t,
      }
    end

    def add_odds(odds_list)
      @odds_list = odds_list
      adjust_params_size
    end

    private

    def adjust_params_size
      @ini_p ||= Probability.new_from_odds(@odds_list[0])
      @t = TrueDistribution.new_from_odds(@odds_list[0]) if @t.size == 1
      @a.extend_to!(@odds_list.size) if @a.size < @odds_list.size
      @b.extend_to!(@odds_list.size) if @b.size < @odds_list.size
    end
  end
end
