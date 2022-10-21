# frozen_string_literal: true

class Race < ApplicationRecord
  belongs_to :race_date
  belongs_to :course
  belongs_to :race_class
end
