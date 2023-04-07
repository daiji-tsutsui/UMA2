# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'

# コースごとのレース番号一覧を取得し，それぞれのレース情報を取得するジョブ
class ScheduleUmaByCourseJob < ApplicationJob
  queue_as :default

  def perform(date, course_name)
    existing_race_nums = []
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      existing_race_nums = top_page.race_nums(date, course_name)
      Rails.logger.debug("Race numbers at #{course_name}: #{existing_race_nums.join(', ')}")
    end

    # コースが表示されているのにレース番号が取れないのはおかしい
    raise "Cannot fetch race numbers at #{course_name}" if existing_race_nums.empty?

    existing_race_nums.each do |race_num|
      next unless race_num.is_a?(Integer)
      next if skip_this_num?(race_num)

      ScheduleUmaByRaceJob.perform_later(date, course_name, race_num)
    end
  end

  private

  # パフォーマンス等の様子見も兼ねて，いくつかのレース以外はスキップする
  def skip_this_num?(num)
    valid_race_num = [7, 8, 9, 10, 11, 12]
    !valid_race_num.include?(num)
  end
end
