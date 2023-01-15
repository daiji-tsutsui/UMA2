# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース結果ページ
  class ResultPage < RaceBasePage
    set_url 'https://race.netkeiba.com/race/result.html{?query*}'

    element :horse_table_link, 'ul.RaceMainMenu > li#navi_shutuba'

    def show_horse_table
      horse_table_link.hover.click
      Netkeiba::RacePage.new
    end
  end
end
