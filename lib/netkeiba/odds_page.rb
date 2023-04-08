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

    ODDS_PAGE_SINGLE_ODDS_CSS = 'td.Odds'

    def single_odds
      select_single_odds_table!
      Rails.logger.debug('1st update_and_fetch_single_odds')
      result = update_and_fetch_single_odds
      return result if seems_ok(result)

      # 変な数値があれば一回だけリトライ
      Rails.logger.debug('2nd update_and_fetch_single_odds')
      update_and_fetch_single_odds
    end

    def single_odds_for_result
      select_single_odds_table!(update: false)
      result = fetch_single_odds
      return result if seems_ok(result)

      # 変な数値があれば一回だけリトライ
      fetch_single_odds
    end

    private

    def select_single_odds_table!(update: true)
      single_odds_table_link.hover.click
      wait_until_single_odds_table_visible
      return self unless update

      wait_until_last_odds_update_date_visible
      self
    end

    def update_and_fetch_single_odds
      2.times do
        odds_update_button.hover.click
        wait_until_last_odds_update_date_visible
      end
      sleep(0.5)
      fetch_single_odds
    end

    def fetch_single_odds
      single_odds_table.all(ODDS_PAGE_SINGLE_ODDS_CSS).map(&:text)
    end

    def seems_ok(array)
      !array.map(&:to_f).include?(0.0)
    end
  end
end
