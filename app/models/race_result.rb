# frozen_string_literal: true

# Model class for 'race_results' table
class RaceResult < ApplicationRecord
  belongs_to :race

  # Array of hashes like { order: 1, number: 2, race_horse_id: 3 }
  def data
    @data ||= JSON.parse(data_json)
  end

  # Array
  def odds
    @odds ||= JSON.parse(odds_json)
  end
end
