# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース結果ページ
  class ResultPage < RaceBasePage
    set_url 'https://race.netkeiba.com/race/result.html{?query*}'

    element :result_table, 'table#All_Result_Table'

    def result_info
      result = result_table.find_all('tbody > tr.HorseList')
      result.map.with_index(1) do |horse, i|
        {
          order:  i,
          name:   horse.first('td', class: 'Horse_Info').text,
          weight: get_weight(horse),
        }
      end
    end

    private

    def get_weight(horse)
      weight_str = horse.first('td', class: 'Weight').text
      RACE_PAGE_CURRENT_WEIGHT_PATTERN =~ weight_str ? $1 : weight_str
    rescue Capybara::ExpectationNotMet
      ''
    end
  end
end
