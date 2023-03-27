# frozen_string_literal: true

module RaceHelper
  ROUND_FLOAT     = 2
  ROUND_WEIGHT    = 4
  ROUND_CERTAINTY = 2

  def display_float(number)
    return number unless number.is_a?(Float)

    number.round(ROUND_FLOAT)
  end

  def display_weight(number)
    number.nil? ? '' : number.round(ROUND_WEIGHT)
  end

  def display_certainty(number)
    number.nil? ? '' : number.round(ROUND_CERTAINTY)
  end

  def frame_css(frame)
    "raceframe-#{frame}"
  end

  def frame_css_from_number(number)
    race_horse = get_race_horse_by_number(number)
    race_horse.nil? ? '' : frame_css(race_horse.frame)
  end

  def odds_css(value)
    return 'zero' if value.zero?
    return 'dominant' if value < 10.0
    ''
  end

  def true_distribution_css(value)
    return 'zero' if value.round(ROUND_FLOAT).zero?
    return 'dominant' if value > 0.10
    ''
  end

  def strategy_css(value)
    return 'zero' if value.zero?
    ''
  end

  def order_css(order)
    return "resultorder-#{order}" if [1, 2, 3].include? order
    'resultorder-rest'
  end

  def tooltip_horse_name(number)
    race_horse = get_race_horse_by_number(number)
    race_horse.nil? ? '' : race_horse.horse.name
  end

  def sort(result_array)
    result_array.sort { |h1, h2| h1['number'] <=> h2['number'] }
  end

  def actual_gain(strategy)
    number = get_win_horse_number
    return '' if number.nil?

    actual_bet = strategy[number.to_i - 1]
    actual_bet * get_win_horse_odds(number)
  end

  private

  def get_race_horse_by_number(number)
    return nil if @race.nil?

    @race.race_horses.find do |race_horse|
      race_horse.number == number
    end
  end

  def get_win_horse_number
    return nil if @race.nil?

    result = @race.race_result.data
    result.find { |horse| horse['order'] == 1 }['number']
  end

  def get_win_horse_odds(number)
    return nil if @race.nil?

    final_odds = @race.race_result.odds
    final_odds[number.to_i - 1]
  end
end
