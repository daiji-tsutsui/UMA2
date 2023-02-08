# frozen_string_literal: true

# Model class for 'races' table
class Race < ApplicationRecord
  belongs_to :race_date
  belongs_to :course
  belongs_to :race_class
  has_many   :race_horses
  has_many   :odds_histories

  scope :sort_by_date, -> { order(race_date_id: :DESC, course_id: :ASC, number: :ASC) }

  def self.search(params)
    # TODO: dateに対応したい．2023-01とかで検索できるように
    result = Race.all
    result.where!('name LIKE ?', "%#{params[:name]}%") unless params[:name].blank?
    result.where!(course_id: params[:course])          unless params[:course].blank?
    result.where!(number: params[:number])             unless params[:number].blank?
    result.where!(race_class_id: params[:race_class])  unless params[:race_class].blank?
    result
  end
end
