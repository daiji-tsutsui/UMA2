# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Jra
  # オッズ情報レース選択ページ
  class RaceOddsPage < SitePrism::Page
    set_url 'https://sp.jra.jp/JRADB/accessO.html'

    # レース番号
    RACE_NUMBER_1 = 0
    RACE_NUMBER_2 = 1
    RACE_NUMBER_3 = 2
    RACE_NUMBER_4 = 3
    RACE_NUMBER_5 = 4
    RACE_NUMBER_6 = 5
    RACE_NUMBER_7 = 6
    RACE_NUMBER_8 = 7
    RACE_NUMBER_9 = 8
    RACE_NUMBER_10 = 9
    RACE_NUMBER_11 = 10
    RACE_NUMBER_12 = 11
    # オッズの種類
    ODDS_TYPE_TEXT_SINGLE = '単勝・複勝'

    elements :races, 'li.oddsRaceListCol'

    def go_single_odds(num)
      race = races[num].all(:css, 'li>a')
      race.each do |type|
        if type.text == ODDS_TYPE_TEXT_SINGLE
          type.hover.click
          return SingleOddsPage.new
        end
      end
    end
  end
end
