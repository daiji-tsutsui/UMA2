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

    # 出馬情報が取れていないのはおかしい
    raise "Cannot fetch horses at #{course_name} #{race_num}R" if horses.blank?

    race_horse_ids = register_or_fetch_ids(horses, race_id)

    # UMAのスケジュール
    FetchOddsAndDoUmaJob.perform_later(date, race_horse_ids) unless race_horse_ids.empty?
  end

  private

  def register_or_fetch_ids(horses, race_id)
    race_horse_ids = []
    horses.each do |horse_info|
      # 馬情報のINSERT
      horse_id = register_horse(horse_info[:name])

      # 出馬情報のINSERT
      race_horse_id = register_race_horse(horse_info[:race_horse], race_id, horse_id)
      race_horse_ids.push(race_horse_id) unless race_horse_id.nil?
    end
    race_horse_ids
  end

  def register_horse(horse_name)
    horse = nil
    Retryable.retryable(on: [ActiveRecord::RecordNotUnique], tries: 5) do
      Horse.transaction do
        horse = Horse.find_or_create_by(name: horse_name)
      end
    end
    horse.id
  end

  def register_race_horse(race_horse_info, race_id, horse_id)
    race_horse_hash = race_horse_info.merge({
      race_id:  race_id,
      horse_id: horse_id,
    })
    race_horse = nil
    begin
      race_horse = RaceHorse.create(race_horse_hash)
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.debug("RaceHorse has already been registered: #{race_horse_hash}")
      return nil
    end
    race_horse.id
  end
end
