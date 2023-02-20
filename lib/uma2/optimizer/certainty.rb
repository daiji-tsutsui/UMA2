# frozen_string_literal: true

module Uma2
  class Optimizer
    # Certainty parameter for odds forecasting model
    class Certainty < Uma2::Positives
      def update
        raise 'Define Me'
      end
    end
  end
end
