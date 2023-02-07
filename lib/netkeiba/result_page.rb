# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース結果ページ
  class ResultPage < RaceBasePage
    set_url 'https://race.netkeiba.com/race/result.html{?query*}'
  end
end
