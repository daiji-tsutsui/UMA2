# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'
require 'json'

# オッズ情報を取得し，UMAを呼ぶジョブ
class FetchOddsAndDoUmaJob < ApplicationJob
  queue_as :default

  def perform(race_id)
    date, course_name, race_num = fetch_race_info(race_id)

    odds_info = []
    Capybara.reset_sessions!
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      race_page = top_page.go_race_page(date, course_name, race_num)
      odds_info = race_page.go_odds_page.single_odds(race_id)
    end

    # オッズ情報が取れていないのはおかしい
    raise "Cannot fetch odds at #{course_name} #{race_num}R" if odds_info.blank?

    odds_history_id = register(race_id, odds_info)
    DoUmaJob.perform_later(race_id, odds_history_id, is_first: true)
  end

  private

  def register(race_id, odds_info)
    json = odds_info.map(&:to_f).to_json
    odds_history = OddsHistory.create({ race_id: race_id, data_json: json })
    odds_history.id
  end
end
