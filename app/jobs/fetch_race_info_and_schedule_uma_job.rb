# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'

# 開催レースの情報を取得し，オッズ追跡をスケジュールするジョブ
class FetchRaceInfoAndScheduleUmaJob < ApplicationJob
  queue_as :default

  def perform
    date = Date.today
    # date = Date.parse('2023-01-05')  # For debug
    Rails.logger.debug("Date: #{date.strftime('%Y%m%d')}")

    Capybara.default_driver = :selenium_chrome_headless
    course_names = []
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      course_names = top_page.course_names(date)
      Rails.logger.debug("Couses fetched: \n#{course_names.join("\n")}")
      # TODO: 結果が空の場合の処理
    end

    course_names.each do |name|
      name = formal_course_name(name)
      FetchRaceInfoJob.perform_async(name) unless name.nil?
    end
  end

  private

  def formal_course_name(text)
    @courses_all ||= Course.all
    names = @courses_all.select { |course| text.include? course.name }
    if names.empty?
      Rails.logger.warn("Cannot pick course name from original text: #{text}")
      return nil
    end
    names[0]
  end
end
