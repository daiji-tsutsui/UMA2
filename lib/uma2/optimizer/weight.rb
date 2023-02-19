# frozen_string_literal: true

require 'uma2/probability'

module Uma2
  class Optimizer
    # Weight parameter for odds forecasting model
    class Weight < Probability
      def update
        raise 'Define Me'
      end
    end
  end
end
