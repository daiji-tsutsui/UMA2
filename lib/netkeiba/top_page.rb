# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース情報トップページ
  class TopPage < SitePrism::Page
    set_url 'https://race.netkeiba.com/top/'

    element :race_list, 'div#race_list'
    element :date_list, 'ul#date_list_sub'

    # 各レース情報ページへ遷移
    def go_race_page(date, course, race_num)
      res = select_date(date)
      return nil if res.nil?

      course_table = select_course(course)
      return nil if course_table.nil?

      race = select_race(course_table, race_num)
      return nil if race.nil?

      @is_finished = finished?(race)
      race.first('a').hover.click
      (@is_finished ? Netkeiba::ResultPage.new : Netkeiba::RacePage.new)
    end

    # 日付とコース名に対するレース名の一覧
    def race_names(date, course)
      res = select_date(date)
      return [] if res.nil?

      table = select_course(course)
      return [] if table.nil?

      races = table.all('li.RaceList_DataItem', visible: false)
      races.map { |race| race.first('span.ItemTitle').text }
    end

    # 日付に対するコース名の一覧
    def course_names(date)
      res = select_date(date)
      return [] if res.nil?

      table = race_list.first("div##{@date_id}")
      table.all('p.RaceList_DataTitle').map(&:text)
    end

    private

    # 指定された日付をクリックし，その日のレース一覧を表示
    # 成功すればselfを，失敗すればnilを返す
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

    # コース名で指定し，レース一覧を返す．失敗すればnilを返す
    # select_dateされていることが前提
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

    # レース一個の要素を返す．失敗したらnilを返す
    def select_race(course_table, race_num)
      races = course_table.all('li.RaceList_DataItem')
      races.each do |race|
        # 10R, 11Rだけ公開されていることがあるため，textで判断する
        # Rails.logger.debug("'#{race.first('div.Race_Num').text}'")
        return race if race.first('div.Race_Num').has_text?(/\A#{race_num}R\z/)
      end
      Rails.logger.debug("There are no races with race number #{race_num}R")
      nil
    end

    # レース要素が確定済みか否か判定
    def finished?(race)
      race.first('a')['href'].match?(/result\.html/)
    end
  end
end
