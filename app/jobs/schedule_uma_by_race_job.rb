# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'

# レースごとの情報を取得するジョブ
class ScheduleUmaByRaceJob < ApplicationJob
  queue_as :default

  def perform(date, course_name, race_num)
    # Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
    #   top_page = Netkeiba::TopPage.new
    #   top_page.load
    #   existing_race_nums = top_page.race_nums(date)
    #   if existing_race_nums.empty?
    #     Rails.logger.error("Cannot fetch race numbers at #{course_name}. Something went wrong.")
    #     return
    #   end
    #   Rails.logger.debug("Race numbers at #{course_name}: #{existing_race_nums.join(', ')}")
    # end

    # existing_race_nums.each do |race_num|
    #   ScheduleUmaByRaceJob.perform_later(date, course_name, race_num)
    # end
  end
end