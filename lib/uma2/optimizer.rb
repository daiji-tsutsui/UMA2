# frozen_string_literal: true

require 'uma2/optimizer/weight'
require 'uma2/optimizer/certainty'
require 'uma2/optimizer/true_distribution'

module Uma2
  # Optimizer of odds forecasting model
  class Optimizer
    def initialize
      @a = Weight.new
      @b = Certainty.new
      @t = TrueDistribution.new
    end

    def params
      @params ||= {
        a: @a,
        b: @b,
        t: @t,
      }
    end
  end
end
