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
      selector = "li[date='#{date_str}']"
      return nil unless date_list.has_selector?(selector)

      date_link = date_list.first(selector)
      @date_id = date_link['aria-controls']
      date_link.hover.click
      self
    end

    def go_race_page(course, number)
      course_table = select_course(course)
      return nil if course_table.nil?

      race = course_table.all('li.RaceList_DataItem')[number.to_i - 1]
      @is_finished = is_finished(race)
      race.first('a').hover.click
      (@is_finished ? Netkeiba::ResultPage.new : Netkeiba::RacePage.new)
    end

    private

    def select_course(name)
      return nil if @date_id.blank?

      table = race_list.first("div##{@date_id}")
      courses = table.all('dl.RaceList_DataList', visible: false)
      courses.each do |course_table|
        course_title = course_table.first('div.RaceList_DataHeader_Top')
        return course_table if course_title.has_text?(name)
      end
      nil
    end

    def is_finished(race)
      race.first('a')['href'].match?(/result\.html/)
    end
  end
end
