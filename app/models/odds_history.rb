# frozen_string_literal: true

require 'json'

# Model class for 'odds_histories' table
class OddsHistory < ApplicationRecord
  belongs_to :race

  scope :until_now, ->(race_id, last_id) { where(race_id: race_id, id: ..last_id).order(id: :ASC) }

  # Array of Float (for optimization)
  def data
    return @data if @data.present?

    @data = data_for_display.reject(&:zero?)
  end

  def data_for_display
    @data_for_display ||= JSON.parse(data_json)
  end
end
