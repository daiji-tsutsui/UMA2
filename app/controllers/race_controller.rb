# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  ERROR_MESSAGE_NO_SUCH_RACE = 'No such a race...'

  def index
    @races = Race.search(search_params)
                 .sort_by_date
                 .preload(:race_date, :race_class, :course)
                 .paginate(page: params[:page])
  end

  def show
    @race = Race.includes(race_horses: :horse)
                .find(params[:id])
    @odds_histories = @race.odds_histories # DESC
    @optimized_params = optimized_params(@race)
    return unless @race.nil?

    flash[:danger] = ERROR_MESSAGE_NO_SUCH_RACE
    redirect_to races_path
  end

  private

  def search_params
    params.permit(:name, :date, :course, :number, race_class: [])
  end

  def optimized_params(race)
    process = race.optimization_process
    return dummy_params if process.nil?

    params = process.params
    params.each { |_key, val| val.reverse! }
    params
  end

  def dummy_params
    {
      'a' => [],
      'b' => [],
      't' => [],
    }
  end
end
