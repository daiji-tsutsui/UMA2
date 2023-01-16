class RaceHorse < ApplicationRecord
  belongs_to :race
  belongs_to :horse
end
