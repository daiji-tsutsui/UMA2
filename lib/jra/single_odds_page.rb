# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Jra
  # 単勝・複勝オッズ情報ページ
  class SingleOddsPage < SitePrism::Page
    element :odds_table, 'div.ozTanfukuTable'

    def uma_num
      odds_table.all(:css, 'tr>td.umaban').size
    end

    def uma_name
      odds_table.all(:css, 'tr>td.bamei>a').map(&:text)
    end

    def tan_odds
      odds_table.all(:css, 'tr>td.oztan').map { |odds| odds.text.to_f }
    end

    def fuku_odds
      fuku_area = odds_table.all(:css, 'tr>td.fukuArea')
      fuku_min = []
      fuku_max = []
      fuku_area.each do |area|
        fuku_min.push area.first(:css, 'div.fukuMin').text.to_f
        fuku_max.push area.first(:css, 'div.fukuMax').text.to_f
      end
      { min: fuku_min, max: fuku_max }
    end
  end
end
