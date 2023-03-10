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
      @loss = 1000.0
      @is_converged = false
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
      (1..iteration).each do |i|
        update!
        check_interval = Settings.uma2.check_loss_interval
        check_loss_decreasing(loss) if (i % check_interval).zero?
      end
      @loss
    end

    def loss
      # updateの後に呼ぶこと
      return 0.0 if @model.nil?

      @model.loss(@odds_list)
    end

    def converges?
      @is_converged
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
      old_a = @a.clone
      old_b = @b.clone
      old_t = @t.clone
      @a.update(@odds_list, @model)
      @b.update(@odds_list, @model, old_a, old_t)
      @t.update(@odds_list, @model, old_a, old_b)
    end

    def check_loss_decreasing(new_loss)
      check_margin = Settings.uma2.check_loss_margin
      conv_margin = Settings.uma2.convergence_margin
      if @loss - new_loss > check_margin # 有意に増加が認められたら警告しておく
        Rails.logger.warn("Loss function increasing!! #{@loss} -> #{new_loss}")
      end
      @is_converged = (@loss - new_loss < conv_margin)
      @loss = new_loss
    end
  end
end
