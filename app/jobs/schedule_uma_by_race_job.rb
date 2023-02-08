# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'
require 'retryable'

# レースごとの情報を取得するジョブ
# UMAのスケジュールもする
class ScheduleUmaByRaceJob < ApplicationJob
  queue_as :default

  RACE_CLASS_OTHERS = 4
  RACE_CLASS_NONE   = 5

  def perform(date, course_name, race_num)
    race_info = { date: date, course_name: course_name }
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      race_page = top_page.go_race_page(date, course_name, race_num)

      raise "Cannot go to Netkeiba race page: #{course_name} - #{race_num}R" if race_page.nil?

      race_info.merge!(race_page.race_info)
    end

    # レース名が取れていないのはおかしい
    raise "Cannot fetch info at #{course_name} #{race_num}R" unless race_info.key?(:name)

    # レース情報のINSERT
    race_hash = format_for_insert(race_info)
    race = Race.create(race_hash)

    # UMAのスケジュール
    ScheduleUmaWithRegisteringHorsesJob.perform_later(race.id)
  end

  private

  def format_for_insert(race_info)
    {
      name:          race_info[:name],
      number:        race_info[:number],
      weather:       race_info[:weather],
      distance:      race_info[:distance],
      course_type:   race_info[:course_type],
      starting_time: race_info[:starting_time],
      race_date_id:  race_date_id(race_info[:date]),
      course_id:     course_id(race_info[:course_name]),
      race_class_id: race_class_id(race_info[:race_class]),
    }
  end

  def race_date_id(date)
    race_date = nil
    Retryable.retryable(on: [ActiveRecord::RecordNotUnique], tries: 5) do
      ActiveRecord::Base.transaction do
        race_date = RaceDate.find_or_create_by(value: date)
      end
    end
    race_date.id
  end

  def course_id(name)
    course = Course.find_by(name: name)
    if course.nil?
      Rails.logger.debug("There are no such course #{name}")
      return nil
    end
    course.id
  end

  def race_class_id(name)
    race_class = RaceClass.find_by(name: name)
    race_class.nil? ? RACE_CLASS_NONE : race_class.id
  end
end
