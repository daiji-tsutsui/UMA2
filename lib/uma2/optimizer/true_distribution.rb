# frozen_string_literal: true

module Uma2
  class Optimizer
    # True distribution parameter for odds forecasting model
    class TrueDistribution < Uma2::Probability
      def update
        raise 'Define Me'
      end
    end
  end
end
