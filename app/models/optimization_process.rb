# frozen_string_literal: true

require 'json'

# Uma2 optimization processes for each race
class OptimizationProcess < ApplicationRecord
  def params
    @params ||= JSON.parse(params_json)
  end
end
