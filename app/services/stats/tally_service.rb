# frozen_string_literal: true

module Stats
  # Service object class which tallies race results
  class TallyService
    def initialize(races, dates, params)
      @races = races
      @dates = dates
      @params = params
    end

    def call
      @dates.to_h do |date|
        targets = targets(date)
        [date.id, tally(targets)]
      end
    end

    private

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
      return format(Array.new(9, 0.0)) if matrix.empty?

      calculate(matrix)
    end

    def tally_each_race(race)
      proposer = proposer(race)
      race_result = race.race_result

      gain_actual, gain_expected = tally_stragety(race_result, proposer.gain_strategy)
      hit_actual, hit_expected = tally_stragety(race_result, proposer.hit_strategy)
      [gain_actual, gain_expected, hit_actual, hit_expected]
    end

    def proposer(race)
      odds = race.last_odds.data
      race.optimization_process.proposer(odds, option: @params)
    end

    def tally_stragety(race_result, strategy)
      actual_gain = race_result.actual_gain(strategy)
      expected_gain = strategy.expected_gain
      [actual_gain, expected_gain]
    end

    def calculate(matrix)
      size = matrix.size
      sums = matrix.transpose.map(&:sum)
      averages = sums.map { |val| val / size }
      format([averages, sums, size].flatten)
    end

    def format(result)
      {
        gain_actual:   result[0],
        gain_expected: result[1],
        hit_actual:    result[2],
        hit_expected:  result[3],
        gain_total:    result[4],
        hit_total:     result[6],
        target_size:   result[8],
      }
    end
  end
end
