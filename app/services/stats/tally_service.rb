# frozen_string_literal: true

module Stats
  # Service object class which tallies race results
  class TallyService
    def initialize(races, dates)
      @races = races
      @dates = dates
    end

    def call
      @dates.map do |date|
        targets = targets(date)
        [date.id, tally(targets)]
      end.to_h
    end

    private

    def bet
      Settings.app.race.bet
    end

    def targets(date)
      @races.select do |race|
        race.race_date.id == date.id \
        && race.last_odds.present? \
        && race.optimization_process.present? \
        && race.race_result.present?
      end
    end

    def tally(targets)
      matrix = targets.map { |race| tally_each_race(race) }
      return format(Array.new(4, 0.0)) if matrix.empty?

      average(matrix)
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
      size = values.size
      sums = values.transpose.map(&:sum)
      format(sums.map { |val| val / size })
    end

    def format(result)
      {
        gain_actual:   result[0],
        gain_expected: result[1],
        hit_actual:    result[2],
        hit_expected:  result[3],
      }
    end
  end
end
