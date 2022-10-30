# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Jra
  # 今週のオッズボタン用
  SATURDAY = 0
  SUNDAY = 1
  THIRD = 2

  # オッズ情報コース・日時選択ページ
  class OddsPage < SitePrism::Page
    set_url 'https://sp.jra.jp/JRADB/accessO.html'

    elements :days, 'div#ThisWkOdds>div.joSelectArea'

    def choose_course(day_id, region)
      courses = days[day_id].all(:css, 'div.jyoSelectBtn')
      courses.each do |course|
        if course.text == region
          course.hover.click
          break
        end
      end
      RaceOddsPage.new
    end
  end
end
