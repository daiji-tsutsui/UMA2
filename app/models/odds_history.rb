# frozen_string_literal: true

# Model class for 'odds_histories' table
class OddsHistory < ApplicationRecord
  belongs_to :race
end
