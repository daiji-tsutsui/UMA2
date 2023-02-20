# frozen_string_literal: true

module Uma2
  class Optimizer
    # Weight parameter for odds forecasting model
    class Weight < Uma2::Probability
      def update
        raise 'Define Me'
      end
    end
  end
end
