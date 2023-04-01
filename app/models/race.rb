# frozen_string_literal: true

# Model class for 'races' table
class Race < ApplicationRecord
  belongs_to :race_date
  belongs_to :course
  belongs_to :race_class
  has_many   :race_horses,    -> { order(number: :ASC) }
  has_many   :odds_histories, -> { order(created_at: :DESC) }
  has_one    :optimization_process
  has_one    :race_result

  scope :sort_by_date, -> { order(race_date_id: :DESC, course_id: :ASC, number: :ASC) }

  def last_odds
    odds_histories.first # DESCなので
  end

  class << self
    def search(params)
      # TODO: dateに対応したい．2023-01とかで検索できるように
      result = Race.all
      add_baseic_conditions!(result, params)
      add_duration_condition!(result, params)
      add_preload!(result)
    end

    private

    def add_baseic_conditions!(model, params)
      model.where!('name LIKE ?', "%#{params[:name]}%") if params[:name].present?
      model.where!(course_id: params[:course])          if params[:course].present?
      model.where!(number: params[:number])             if params[:number].present?
      model.where!(race_class_id: params[:race_class])  if params[:race_class].present?
    end

    def add_duration_condition!(model, params)
      return if params[:duration].blank?

      date_ids = RaceDate.in(params[:duration]).map(&:id)
      model.where!(race_date_id: date_ids)
    end

    def add_preload!(model)
      model.preload(:race_date, :race_class, :course)
    end
  end
end
