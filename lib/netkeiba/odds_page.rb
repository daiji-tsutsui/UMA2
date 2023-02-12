# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのオッズ閲覧ページ
  class OddsPage < RaceBasePage
    set_url 'https://race.netkeiba.com/odds/index.html{?query*}'

    element :single_odds_table_link, 'ul.RaceSubMenu > li#odds_navi_b1'
    element :single_odds_table, 'div#odds_tan_block'
    element :odds_update_button, 'button#act-manual_update'
    element :last_odds_update_date, 'span#official_time'

    ODDS_PAGE_SINGLE_ODDS_CSS = 'span[id^="odds-1_"]'

    def single_odds(race_id)
      @race_id = race_id
      select_single_odds_table!
      result = update_and_fetch_single_odds
      return result unless result.map(&:to_f).include?(0.0)

      # 変な数値があれば一回だけリトライ
      update_and_fetch_single_odds
    end

    private

    def select_single_odds_table!
      single_odds_table_link.hover.click
      wait_until_last_odds_update_date_visible
      self
    end

    def update_and_fetch_single_odds
      result = update_and_fetch_single_odds_without_retry
      return result unless same_single_odds?(result)

      # 前回取得したものと同じ値ならば一回だけリトライ
      update_and_fetch_single_odds_without_retry
    end

    def update_and_fetch_single_odds_without_retry
      odds_update_button.hover.click
      wait_until_last_odds_update_date_visible
      single_odds_table.all(ODDS_PAGE_SINGLE_ODDS_CSS).map(&:text)
    end

    def same_single_odds?(data)
      last_odds = OddsHistory.where(race_id: @race_id).last
      data == last_odds.data
    end
  end
end
