# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース情報系ページの共通クラス
  class RaceBasePage < SitePrism::Page
    set_url 'https://race.netkeiba.com/race/shutuba.html{?query*}'

    element  :race_name,   'div.RaceName'
    element  :race_num,    'span.RaceNum'
    element  :race_data,   'div.RaceData01'
    elements :course_info, 'div.RaceData01 > span'

    RACE_PAGE_CLASS_CSS_G1 = 'Icon_GradeType1'
    RACE_PAGE_CLASS_CSS_G2 = 'Icon_GradeType2'
    RACE_PAGE_CLASS_CSS_G3 = 'Icon_GradeType3'
    RACE_PAGE_STARTING_TIME_PATTERN = /\A(.*)発走/
    RACE_PAGE_COURSE_TYPE_PATTERN   = /\A([^\d]+)\d/
    RACE_PAGE_DISTANCE_PATTERN      = /(\d+)m/

    # レース情報
    def race_info
      {
        name:          race_name.text,
        number:        race_num.text.to_i,
        race_class:    race_class,
        weather:       '', # TODO: 結果が出てから取るか，DBから消すか
        distance:      distance,
        course_type:   course_type,
        starting_time: starting_time,
      }
    end

    def show_horse_table
      self
    end

    private

    def race_class
      return 'G1' if race_name.has_css?("span.#{RACE_PAGE_CLASS_CSS_G1}")
      return 'G2' if race_name.has_css?("span.#{RACE_PAGE_CLASS_CSS_G2}")
      return 'G3' if race_name.has_css?("span.#{RACE_PAGE_CLASS_CSS_G3}")
    end

    def starting_time
      # e.g. "15:35発走 / 芝2000m (左)"
      RACE_PAGE_STARTING_TIME_PATTERN =~ race_data.text ? $1 : nil
    end

    def course_type
      course_info.each do |info|
        # e.g. "芝2000m"
        return $1 if RACE_PAGE_COURSE_TYPE_PATTERN =~ info.text
      end
      nil
    end

    def distance
      course_info.each do |info|
        # e.g. "芝2000m"
        return $1 if RACE_PAGE_DISTANCE_PATTERN =~ info.text
      end
      nil
    end
  end
end
