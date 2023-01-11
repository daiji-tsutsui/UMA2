# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース結果ページ
  class ResultPage < SitePrism::Page
    set_url 'https://race.netkeiba.com/race/result.html{?query*}'

    # TODO: RacePageと共通の親クラスを作るべき
    element :race_name,   'div.RaceName'
    element :race_num,    'span.RaceNum'
    element :race_data,   'div.RaceData01'
  end
end
