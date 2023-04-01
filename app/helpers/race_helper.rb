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

  def gain_css(value)
    return if value.blank?

    value.negative? ? 'gain-nega' : 'gain-posi'
  end

  def tooltip_horse_name(number)
    race_horse = get_race_horse_by_number(number)
    race_horse.nil? ? '' : race_horse.horse.name
  end

  def actual_gain(strategy)
    return unless @race.race_result.present?

    @race.race_result.actual_gain(strategy)
  end

  private

  def get_race_horse_by_number(number)
    @race.race_horses.find { |race_horse| race_horse.number == number }
  end
end
