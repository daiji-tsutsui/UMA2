# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース情報ページ
  class RacePage < RaceBasePage
    set_url 'https://race.netkeiba.com/race/shutuba.html{?query*}'

    element :horse_table, 'table.Shutuba_Table'

    RACE_PAGE_CURRENT_WEIGHT_PATTERN = /\A(\d+)\(.*\)/

    # レース情報
    # TODO: 出馬表もまとめる
    def race_info
      result = super
      result[:horses] = horse_info
      result
    end

    private

    def horse_info
      horse_table.find_all('tbody > tr.HorseList').map do |horse|
        {
          frame:  horse.first('td', class: /\AWaku/).text,
          number: horse.first('td', class: /\AUmaban/).text,
          name:   horse.first('td', class: 'HorseInfo').text,
          sexage: horse.first('td', class: 'Barei').text,
          jockey: horse.first('td', class: 'Jockey').text,
          weight: current_weight(horse.first('td', class: 'Weight').text),
        }
      end
    end

    def current_weight(weight_str)
      return (RACE_PAGE_CURRENT_WEIGHT_PATTERN =~ weight_str ? $1 : weight_str)
    end
  end
end
