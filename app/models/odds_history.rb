# frozen_string_literal: true

require 'json'

# Model class for 'odds_histories' table
class OddsHistory < ApplicationRecord
  belongs_to :race

  scope :until_now, ->(race_id, last_id) { where(race_id: race_id, id: ..last_id).order(id: :asc) }

  def data
    # Array of Float
    @data ||= JSON.parse(data_json)
  end
end
