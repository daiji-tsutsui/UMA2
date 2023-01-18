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
    horses = []
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      race_page = top_page.go_race_page(date, course_name, race_num)
      horse_table_page = race_page.show_horse_table

      raise "Cannot get horse table: #{course_name} - #{race_num}R" if horse_table_page.nil?

      horses = horse_table_page.horses_info
    end

    race_horse_ids = register(horses, race_id)

    # UMAのスケジュール
    FetchOddsAndDoUmaJob.perform_later(date, race_horse_ids)
  end

  private

  def register(horses, race_id)
    race_horse_ids = []
    horses.each do |horse_info|
      # 馬情報のINSERT
      horse = register_horse(horse_info[:name])

      # 出馬情報のINSERT
      race_horse = register_race_horse(horse_info[:race_horse], race_id, horse.id)
      race_horse_ids.push(race_horse.id)
    end
    race_horse_ids
  end

  def register_horse(horse_name)
    horse = nil
    Retryable.retryable(on: [ActiveRecord::RecordNotUnique], tries: 5) do
      ActiveRecord::Base.transaction do
        horse = Horse.find_or_create_by(name: horse_name)
      end
    end
    horse
  end

  def register_race_horse(race_horse_info, race_id, horse_id)
    race_horse_hash = race_horse_info.merge({
      race_id:  race_id,
      horse_id: horse_id,
    })
    RaceHorse.create(race_horse_hash)
  end
end
