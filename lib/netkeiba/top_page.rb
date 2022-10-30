# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース情報トップページ
  class TopPage < SitePrism::Page
    set_url 'https://race.netkeiba.com/top/'

    element :race_list, 'div#race_list'
    element :date_list, 'ul#date_list_sub'

    def select_date(date)
      date_str = date.is_a?(Date) ? date.strftime('%Y%m%d') : date
      date_link = date_list.first("li[date='#{date_str}']")
      @date_id = date_link['aria-controls']
      date_link.hover.click
      self
    end

    def go_race_page(course, number)
      course_table = select_course(course)
      # TODO: 不正なコース名処理
      return nil if course_table.nil?

      races = course_table.find('div.RaceList_DataItem')
      number = number.to_i
      races[number - 1].first('a').click
      Netkeiba::RacePage.new
    end

    private

    def select_course(name)
      table = race_list.first("div#{@date_id}")
      courses = table.find('div.RaceList_DataList')
      courses.each do |course_table|
        course_title = course_table.first('div.RaceList_DataHeader_Top')
        return course_table if course_title.has_content?(name)
      end
      nil
    end
  end
end
