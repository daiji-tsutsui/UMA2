# frozen_string_literal: true

class Horse < ApplicationRecord
  has_many :race_horses
  belongs_to :race_horse, foreign_key: 'last_race_horse_id', optional: true
end
