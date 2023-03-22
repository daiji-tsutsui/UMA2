# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'
require 'json'

# レースが終わった頃に結果を取りに行くジョブ
class FetchResultJob < ApplicationJob
  queue_as :default

  # TODO: 推定結果との比較，統計がしやすいようにフォーマットする
  # TODO: 天気とったり，完了フラグも立てたい
  def perform(race_id)
    date, course_name, race_num = fetch_race_info(race_id)

    result_info = []
    final_odds_info = []
    Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
      top_page = Netkeiba::TopPage.new
      top_page.load
      result_page = top_page.go_race_page(date, course_name, race_num)
      raise "Cannot go to Netkeiba result page: #{course_name} - #{race_num}R" if result_page.nil?

      result_info, final_odds_info = fetch_info(result_page)
      # レース結果が取れていないのはおかしい
      raise "Cannot fetch result info at #{course_name} #{race_num}R" if result_info.empty?
      # オッズ情報が取れていないのはおかしい
      raise "Cannot fetch final odds at #{course_name} #{race_num}R" if final_odds_info.blank?
    end

    # 馬体重の情報はレース前に取れていないのでここで更新
    update_horse_weights(race_id, result_info)

    # レース結果のINSERT
    create_race_result(race_id, result_info, final_odds_info)
  end

  private

  def fetch_info(result_page)
    result_info = result_page.result_info
    final_odds_info = result_page.go_odds_page.single_odds_for_result

    [result_info, final_odds_info]
  end

  def update_horse_weights(race_id, result_info)
    race_horses = RaceHorse.preload(:horse).where(race_id: race_id)
    result_info.each do |horse|
      race_horse = race_horses.find { |record| record.horse.name == horse[:name] }
      race_horse.update(weight: horse[:weight])
    end
  end

  def create_race_result(race_id, result_info, odds_info)
    formatted_result = format_for_insert(race_id, result_info)
    RaceResult.create!({
      race_id:   race_id,
      data_json: formatted_result.to_json,
      odds_json: odds_info.map(&:to_f).to_json,
    })
  end

  def format_for_insert(race_id, result_info)
    race_horses = RaceHorse.preload(:horse).where(race_id: race_id)
    result_info.map do |horse|
      race_horse = race_horses.find { |record| record.horse.name == horse[:name] }
      {
        order:         horse[:order],
        number:        race_horse.number,
        race_horse_id: race_horse.id,
      }
    end
  end
end
