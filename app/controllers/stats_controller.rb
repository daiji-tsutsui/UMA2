# frozen_string_literal: true

# Stats information Controller
class StatsController < ApplicationController
  DEFAULT_INTERVAL = 1.month

  def index
    build_duration
  end

  def api
    races = Race.search(search_params)
                .preload(:odds_histories, :optimization_process, :race_result)
    dates = RaceDate.in(@start..@end)
    tally_result = Stats::TallyService.new(races, dates, strategy_params).call

    render json: format_response(dates, [tally_result])
  end

  private

  def search_params
    build_duration
    params.permit(:course, :number, race_class: [])
          .merge(duration: @start..@end)
  end

  def strategy_params
    params.permit(:certainty, :minimum_hit)
  end

  def format_response(dates, tally_results)
    {
      averages: average_overall(tally_results.map(&:values)),
      time_seq: reconcile(dates, tally_results),
    }
  end

  def average_overall(tally_results)
    results = tally_results.map do |tally_result|
      data_num = tally_result.sum { |row| row[:target_size] }
      total_keys = tally_result.first.keys.select { |key| /_total\z/ =~ key.to_s }
      total_keys.to_h do |key|
        average = tally_result.sum { |row| row[key] } / data_num
        new_key = key.to_s.gsub(/_total\z/, '_average')
        [new_key, average]
      end
    end
    results.reduce({}, :merge)
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
    @start = @end - DEFAULT_INTERVAL if @end <= @start
  end

  def build_duration_start
    @start = Date.parse(params[:date_start])
  rescue Date::Error, TypeError
    @start = Date.today - DEFAULT_INTERVAL
  end

  def build_duration_end
    @end = Date.parse(params[:date_end])
  rescue Date::Error, TypeError
    @end = Date.today
  end
end
