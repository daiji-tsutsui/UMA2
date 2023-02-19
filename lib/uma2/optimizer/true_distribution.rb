# frozen_string_literal: true

require 'uma2/probability'

module Uma2
  class Optimizer
    # True distribution parameter for odds forecasting model
    class TrueDistribution < Probability
      def update
        raise 'Define Me'
      end
    end
  end
end
