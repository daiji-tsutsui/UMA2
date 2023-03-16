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
    @optimized_params = optimized_params
    @proposer = proposer(10)
    return unless @race.nil?

    flash[:danger] = ERROR_MESSAGE_NO_SUCH_RACE
    redirect_to races_path
  end

  private

  def search_params
    params.permit(:name, :date, :course, :number, race_class: [])
  end

  def optimized_params
    {
      a: process_params['a'].reverse,
      b: process_params['b'].reverse,
      t: process_params['t'],
    }
  end

  def proposer(bet)
    odds = @race.odds_histories.first.data
    Uma2::Proposer.new(process_params, odds, bet)
  end

  def process_params
    return @process_params unless @process_params.nil?

    process = @race.optimization_process
    return dummy_params if process.nil?

    @process_params = process.params
  end

  def dummy_params
    {
      'a' => [],
      'b' => [],
      't' => [],
    }
  end
end
