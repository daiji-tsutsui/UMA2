# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Jra
  # オッズ情報レース選択ページ
  class RaceOddsPage < SitePrism::Page
    set_url 'https://sp.jra.jp/JRADB/accessO.html'

    # オッズの種類
    ODDS_TYPE_TEXT_SINGLE = '単勝・複勝'

    elements :races, 'li.oddsRaceListCol'

    def go_single_odds(number)
      race = races[number - 1].all(:css, 'li>a')
      race.each do |type|
        if type.text == ODDS_TYPE_TEXT_SINGLE
          type.hover.click
          return SingleOddsPage.new
        end
      end
    end
  end
end
