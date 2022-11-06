# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース情報トップページ
  class TopPage < SitePrism::Page
    set_url 'https://race.netkeiba.com/top/'

    element :race_list, 'div#race_list'
    element :date_list, 'ul#date_list_sub'

    def go_race_page(date, course, number)
      res = select_date(date)
      return nil if res.nil?

      course_table = select_course(course)
      return nil if course_table.nil?

      race = course_table.all('li.RaceList_DataItem')[number.to_i - 1]
      @is_finished = finished?(race)
      race.first('a').hover.click
      (@is_finished ? Netkeiba::ResultPage.new : Netkeiba::RacePage.new)
    end

    def race_names(date, course)
      res = select_date(date)
      return [] if res.nil?

      table = select_course(course)
      return [] if table.nil?

      races = table.all('li.RaceList_DataItem', visible: false)
      races.map { |race| race.first('span.ItemTitle').text }
    end

    private

    def select_date(date)
      selector = "li[date='#{date.strftime('%Y%m%d')}']"
      date_link = nil
      begin
        date_link = date_list.first(selector)
      rescue Capybara::ExpectationNotMet => _e
        Rails.logger.debug("There are no selectors #{selector} in ul#date_list_sub")
        return nil
      end
      @date_id = date_link['aria-controls']
      date_link.hover.click
      self
    end

    def select_course(name)
      return nil if @date_id.blank?

      table = race_list.first("div##{@date_id}")
      courses = table.all('dl.RaceList_DataList', visible: false)
      courses.each do |course_table|
        course_title = course_table.first('div.RaceList_DataHeader_Top')
        return course_table if course_title.has_text?(name)
      end
      Rails.logger.debug("There are no course tables for #{name} in div##{@date_id}")
      nil
    end

    def finished?(race)
      race.first('a')['href'].match?(/result\.html/)
    end
  end
end
