# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'
require 'retryable'

# レースごとの出馬情報を登録するジョブ
# UMAのスケジュールもする
class ScheduleUmaWithRegisteringHorsesJob < ApplicationJob
  queue_as :default

  def perform(date, course_name, race_num, race_id)
    horse_info = []
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      race_page = top_page.go_race_page(date, course_name, race_num)
      horse_table_page = race_page.show_horse_table

      raise "Cannot get horse table: #{course_name} - #{race_num}R" if horse_table_page.nil?

      horse_info = horse_table_page.horse_info
    end

    # 馬情報のINSERT
    horse = Horse.find_or_create_by(name: horse_info[:name])

    # 出馬情報のINSERT
    race_horse_hash = format_for_insert(horse_info[:race_horse], race_id, horse.id)
    race_horse = RaceHorse.create(race_horse_hash)

    # UMAのスケジュール
    FetchOddsAndDoUmaJob.perform_later(date, race_horse.id)
  end

  private

  def format_for_insert(base_info, race_id, horse_id)
    {
      race_id:  race_id,
      horse_id: horse_id,
      frame:    base_info[:frame],
      number:   base_info[:number],
      sexage:   base_info[:sexage],
      jockey:   base_info[:jockey],
      weight:   base_info[:weight],
    }
  end
end
