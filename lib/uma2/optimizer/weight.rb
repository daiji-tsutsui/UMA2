# frozen_string_literal: true

require 'uma2/probability'

# Weight parameter for odds forecasting model
class Weight < Probability
  def update
    raise 'Define Me'
  end
end
