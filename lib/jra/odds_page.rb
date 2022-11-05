# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Jra
  # オッズ情報コース・日時選択ページ
  class OddsPage < SitePrism::Page
    set_url 'https://sp.jra.jp/JRADB/accessO.html'

    element  :this_week,     'div#ThisWkOdds'
    elements :course_tables, 'div#ThisWkOdds>div.joSelectArea'
    elements :dates,         'div#ThisWkOdds>div.kaisaibi'

    def go_race_odds_page(date, course_name)
      course_table = select_date(date)
      return nil if course_table.nil?

      select_course(course_name, course_table)
    end

    def select_date(date)
      date_id = get_date_id(date)
      (date_id.nil? ? nil : course_tables[date_id])
    end

    private

    def select_course(name, table)
      courses = table.all(:css, 'div.jyoSelectBtn')
      courses.each do |course|
        if course.text == name
          course.hover.click
          return RaceOddsPage.new
        end
      end
      nil
    end

    def get_date_id(date)
      date_str = date.is_a?(Date) ? date.strftime('%-m月%-d日') : date
      dates.each_with_index do |elem, idx|
        return idx if elem.has_text?(date_str)
      end
      nil
    end
  end
end
