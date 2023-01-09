# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'

# コースごとにレース情報を取得するジョブ
class ScheduleUmaByCourseJob < ApplicationJob
  queue_as :default

  def perform(date, course_name)
    Capybara.default_driver = :selenium_chrome_headless
    course_names = []
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      course_names = top_page.course_names(date)
      Rails.logger.debug("Couses fetched: \n#{course_names.join("\n")}")
    end
  end

  private

end
