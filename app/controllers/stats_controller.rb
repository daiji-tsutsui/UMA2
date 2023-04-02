# frozen_string_literal: true

# Stats information Controller
class StatsController < ApplicationController
  def index
    build_duration
  end

  def api
    races = Race.search(search_params)
                .preload(:odds_histories, :optimization_process, :race_result)
    dates = RaceDate.in(@start..@end)
    tally_result = Stats::TallyService.new(races, dates).call

    render json: reconcile(dates, [tally_result])
  end

  private

  def search_params
    build_duration
    params.permit(:course, :number, race_class: [])
          .merge(duration: @start..@end)
  end

  def reconcile(dates, tally_results)
    dates.map do |date|
      result_row = { date: date.value.strftime('%m/%d') }
      tally_results.each do |tally_result|
        result_row.merge!(tally_result[date.id])
      end
      result_row
    end
  end

  def build_duration
    build_duration_start
    build_duration_end
    @start = @end - 1.month if @end <= @start
  end

  def build_duration_start
    @start = Date.parse(params[:date_start])
  rescue Date::Error, TypeError
    @start = Date.today - 1.month
  end

  def build_duration_end
    @end = Date.parse(params[:date_end])
  rescue Date::Error, TypeError
    @end = Date.today
  end
end
