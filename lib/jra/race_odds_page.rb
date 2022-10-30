# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Jra
  # レース番号
  RACE_1 = 0
  RACE_2 = 1
  RACE_3 = 2
  RACE_4 = 3
  RACE_5 = 4
  RACE_6 = 5
  RACE_7 = 6
  RACE_8 = 7
  RACE_9 = 8
  RACE_10 = 9
  RACE_11 = 10
  RACE_12 = 11

  # オッズ情報レース選択ページ
  class RaceOddsPage < SitePrism::Page
    elements :races, 'li.oddsRaceListCol'

    def go_single_odds(race_id)
      race = races[race_id].all(:css, 'li>a')
      race.each do |type|
        if type.text == '単勝・複勝'
          type.hover.click
          break
        end
      end
      SingleOddsPage.new
    end
  end
end
