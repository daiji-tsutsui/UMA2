# frozen_string_literal: true

class RaceHorse < ApplicationRecord
  belongs_to :race
  belongs_to :horse
end
