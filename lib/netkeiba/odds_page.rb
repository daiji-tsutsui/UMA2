# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのオッズ閲覧ページ
  class OddsPage < RaceBasePage
    set_url 'https://race.netkeiba.com/odds/index.html{?query*}'

    element :single_odds_table_link, 'ul.RaceSubMenu > li#odds_navi_b1'
    element :single_odds_table, 'div#odds_tan_block'

    def single_odds
      select_single_odds_table!
      single_odds_table.all('span[id^="odds-1_"]').map(&:text)
    end

    private

    def select_single_odds_table!
      single_odds_table_link.hover.click
      self
    end
  end
end
