# frozen_string_literal: true

require 'json'

# Uma2 optimization processes for each race
class OptimizationProcess < ApplicationRecord
  def params
    @params ||= params_json.nil? ? {} : JSON.parse(params_json)
  end

  def proposer(odds, bet)
    Uma2::Proposer.new(params, odds, bet)
  end
end
