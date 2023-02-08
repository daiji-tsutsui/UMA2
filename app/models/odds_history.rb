# frozen_string_literal: true

require 'json'

# Model class for 'odds_histories' table
class OddsHistory < ApplicationRecord
  belongs_to :race

  def data
    @data ||= JSON.parse(data_json)
  end
end
