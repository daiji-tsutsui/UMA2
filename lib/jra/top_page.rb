# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Jra
  MENU_ITEM_ODDS = 'オッズ'

  # JRAのトップページ
  class TopPage < SitePrism::Page
    set_url 'https://sp.jra.jp'

    elements :menu_items, 'div#quick_menu>ul>li'

    def go_odds_page
      menu_items.each do |item|
        if item.text == MENU_ITEM_ODDS
          item.hover.click
          break
        end
      end
      OddsPage.new
    end
  end
end
