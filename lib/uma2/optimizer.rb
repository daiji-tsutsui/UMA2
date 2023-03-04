# frozen_string_literal: true

require 'uma2/optimizer/weight'
require 'uma2/optimizer/certainty'
require 'uma2/optimizer/true_distribution'
require 'uma2/optimizer/model'

module Uma2
  # Optimizer of odds forecasting model
  class Optimizer
    attr_reader :a, :b, :t

    def initialize(params: {})
      a, b, t = extract(params)
      @a = Weight.new(a)
      @b = Certainty.new(b)
      @t = TrueDistribution.new(t)
    end

    def parameter
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

    def run(iteration)
      iteration.times { |_i| update! }
      loss
    end

    def loss
      # updateの後に呼ぶこと
      return 0.0 if @model.nil?

      @model.loss(@odds_list)
    end

    private

    def extract(params)
      a = params['a'] || params[:a]
      b = params['b'] || params[:b]
      t = params['t'] || params[:t]
      [a, b, t]
    end

    def adjust_params_size
      @ini_p ||= Probability.new_from_odds(@odds_list[0])
      @t = TrueDistribution.new_from_odds(@odds_list[0]) if @t.size < @odds_list[0].size
      @a.extend_to!(@odds_list.size) if @a.size < @odds_list.size
      @b.extend_to!(@odds_list.size) if @b.size < @odds_list.size
    end

    def update!
      @model = Model.new
      @model.forecast(@odds_list, parameter)
      @a.update(@odds_list, @model)
      # @b.update(m, p, q, @odds_list)
      # @t.update(m, p, q, @odds_list)
    end
  end
end
