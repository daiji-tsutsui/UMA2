# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'

class TestJob < ApplicationJob
  queue_as :default

  def perform
    date = Date.today - 1
    course = '阪神'
    Rails.logger.debug("Date: #{date.strftime('%Y%m%d')}, Course: #{course}")

    Capybara.default_driver = :selenium_chrome_headless

    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      race_names = top_page.race_names(date, course)
      # TODO: 結果が空の場合の処理
      Rails.logger.debug("Hello, world!\n#{race_names.join("\n")}")
    end
    'OK'
  end
end
