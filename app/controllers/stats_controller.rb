# frozen_string_literal: true

# Stats information Controller
class StatsController < ApplicationController
  def index; end

  def api
    races = Race.search(search_params)
                .preload(:odds_histories, :optimization_process, :race_result)
    dates = RaceDate.in(@start..@end)
    sequence = dates.map do |date|
      targets = races.select { |race| race.race_date.id == date.id }
      trim!(targets)
      tally_result = tally(targets)
      [date.value, tally_result]
    end

    render json: format(sequence)
  end

  private

  def format(sequence)
    sequence.map do |row|
      {
        date:          row[0].strftime('%m/%d'),
        gain_actual:   row[1][0],
        gain_expected: row[1][1],
        hit_actual:    row[1][2],
        hit_expected:  row[1][3],
      }
    end
  end

  def search_params
    build_duration
    params.permit(:course, :number, race_class: [])
          .merge(duration: @start..@end)
  end

  def build_duration
    build_duration_start
    build_duration_end
    @start = @end - 1.month if @end <= @start
  end

  def build_duration_start
    @start = Date.parse(params[:date_start])
  rescue Date::Error
    @start = Date.today - 1.month
  end

  def build_duration_end
    @end = Date.parse(params[:date_end])
  rescue Date::Error
    @end = Date.today
  end

  def bet
    # TODO: betパラメータ
    params[:bet].present? ? params[:bet].to_i : Settings.app.race.bet
  end

  def trim!(targets)
    targets.select! do |race|
      race.last_odds.present? && race.optimization_process.present? && race.race_result.present?
    end
  end

  def tally(targets)
    values = targets.map { |race| tally_each_race(race) }
    average(values)
  end

  def tally_each_race(race)
    odds = race.last_odds.data
    proposer = race.optimization_process.proposer(odds, bet)
    race_result = race.race_result

    gain_actual, gain_expected = tally_stragety(race_result, proposer.gain_strategy)
    hit_actual, hit_expected = tally_stragety(race_result, proposer.hit_strategy)
    [gain_actual, gain_expected, hit_actual, hit_expected]
  end

  def tally_stragety(race_result, strategy)
    actual_gain = race_result.actual_gain(strategy)
    expected_gain = strategy.expected_gain
    [actual_gain, expected_gain]
  end

  def average(values)
    return Array.new(4, 0.0) if values.empty?

    size = values.size
    sums = values.transpose.map(&:sum)
    sums.map { |val| val / size }
  end
end
