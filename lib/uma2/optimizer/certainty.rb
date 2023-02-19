# frozen_string_literal: true

require 'uma2/positives'

module Uma2
  class Optimizer
    # Certainty parameter for odds forecasting model
    class Certainty < Positives
      def update
        raise 'Define Me'
      end
    end
  end
end
