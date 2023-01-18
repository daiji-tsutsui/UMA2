# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース情報ページ
  class RacePage < RaceBasePage
    set_url 'https://race.netkeiba.com/race/shutuba.html{?query*}'

    element :horse_table, 'table.Shutuba_Table'

    RACE_PAGE_CURRENT_WEIGHT_PATTERN = /\A(\d+)\(.*\)/

    # 出馬情報
    def horses_info
      horse_table.find_all('tbody > tr.HorseList').map do |horse|
        {
          name:       horse.first('td', class: 'HorseInfo').text,
          race_horse: race_horse_info(horse),
        }
      end
    end

    private

    def race_horse_info(horse)
      {
        frame:  horse.first('td', class: /\AWaku/).text.to_i,
        number: horse.first('td', class: /\AUmaban/).text.to_i,
        sexage: horse.first('td', class: 'Barei').text,
        jockey: horse.first('td', class: 'Jockey').text,
        weight: current_weight(horse.first('td', class: 'Weight').text),
      }
    end

    def current_weight(weight_str)
      RACE_PAGE_CURRENT_WEIGHT_PATTERN =~ weight_str ? $1 : weight_str
    end
  end
end
