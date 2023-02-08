# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'

# 開催レースの情報を取得し，オッズ追跡をスケジュールするジョブ
class ScheduleUmaJob < ApplicationJob
  queue_as :default

  def perform
    date = Date.today
    Rails.logger.debug("ScheduleUma: #{date.strftime('%Y%m%d')}")

    course_names = []
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      course_names = top_page.course_names(date)
      Rails.logger.debug("Couses fetched: \n#{course_names.join("\n")}")
    end

    course_names.each do |course_name|
      course_name = formal_course_name(course_name)
      ScheduleUmaByCourseJob.perform_later(date, course_name) unless course_name.nil?
    end
  end

  private

  def formal_course_name(text)
    @courses_all ||= Course.all
    record = @courses_all.find { |course| text.include? course.name }
    if record.nil?
      Rails.logger.warn("Cannot pick course name from original text: #{text}")
      return nil
    end
    record.name
  end
end
