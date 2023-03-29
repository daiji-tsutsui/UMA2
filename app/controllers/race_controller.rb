# frozen_string_literal: true

# Race information Controller
class RaceController < ApplicationController
  ERROR_MESSAGE_NO_SUCH_RACE = 'No such a race...'

  before_action :fetch_settings, only: [:show]

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
    @optimized_parameters = optimized_parameters
    @proposer = proposer
    return unless @race.nil?

    flash[:danger] = ERROR_MESSAGE_NO_SUCH_RACE
    redirect_to races_path
  end

  private

  def search_params
    params.permit(:name, :date, :course, :number, race_class: [])
  end

  def fetch_settings
    @settings = Settings.app.race
  end

  def optimized_parameters
    process = @race.optimization_process
    return empty_parameters if process.nil? || process.params.empty?

    {
      a: process.params['a'].reverse,
      b: process.params['b'].reverse,
      t: process.params['t'],
    }
  end

  def proposer
    process = @race.optimization_process
    return if process.nil?

    odds = @race.odds_histories.first.data
    process.proposer(odds, @settings.bet)
  end

  def empty_parameters
    {
      a: [],
      b: [],
      t: [],
    }
  end
end
