# frozen_string_literal: true

class RaceDate < ApplicationRecord
  has_many :races

  scope :in, ->(duration) { where(value: duration) }
end
