# frozen_string_literal: true

require 'uma2/probability'

# True distribution parameter for odds forecasting model
class TrueDistribution < Probability
  def update
    raise 'Define Me'
  end
end
