# frozen_string_literal: true

class Horse < ApplicationRecord
  has_many :race_horses
  belongs_to :race_horse, foreign_key: 'last_race_horse_id', optional: true

  scope :sort_by_last_race, -> { order(race_id: :DESC, id: :ASC) }

  def self.search(params)
    # TODO: dateに対応したい．2023-01とかで検索できるように
    result = Horse.all
    result = result.where('name LIKE ?', "%#{params[:name]}%") unless params[:name].blank?
    result
  end
end
