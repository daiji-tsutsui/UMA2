# frozen_string_literal: true

# Model class for 'race_results' table
class RaceResult < ApplicationRecord
  belongs_to :race

  # Array of hashes like { order: 1, number: 2, race_horse_id: 3 }
  def data
    @data ||= JSON.parse(data_json)
  end

  def sorted_by_number
    data.sort { |h1, h2| h1['number'] <=> h2['number'] }
  end

  # Array
  def odds
    @odds ||= JSON.parse(odds_json)
  end

  def gain(strategy)
    number = won_number.to_i
    strategy[number - 1] * odds[number - 1]
  end

  private

  def won_number
    data.find { |horse| horse['order'] == 1 }['number']
  end
end
