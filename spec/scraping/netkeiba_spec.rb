# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

NETKEIBA_COURSE_NAMES = %w[札幌 函館 福島 中山 東京 新潟 中京 京都 阪神 小倉].freeze
# DATE_PATTERN = '%-m/%-d'
DATE_PATTERN = '%-m月%-d日'

RSpec.describe 'Netkeiba' do
  before do
    @top_page = Netkeiba::TopPage.new
    @top_page.load
  end

  describe 'top page' do
    it 'is displayed' do
      expect(@top_page).to be_displayed
      expect(@top_page).to have_race_list
      expect(@top_page).to have_date_list
    end

    it 'can get race names and numbers for dates displayed' do
      dates = (-3..3).map { |diff| Date.today + diff }
      can_get = []
      dates.each do |date|
        date_str = date.strftime(DATE_PATTERN)
        next unless @top_page.date_list.has_content?(date_str)

        race_names = []
        NETKEIBA_COURSE_NAMES.each do |course_name|
          race_names = @top_page.race_names(date, course_name)
          next if race_names.empty?

          expect(@top_page.race_nums(date, course_name).size).to be > 0
          can_get.push date_str
          break
        end
      end
      expect(can_get.size).to be > 0
    end

    it 'CANNOT get race names and numbers for dates NOT displayed' do
      dates = (-3..3).map { |diff| Date.today + diff }
      dates.each do |date|
        date_str = date.strftime(DATE_PATTERN)
        next if @top_page.date_list.has_content?(date_str)

        NETKEIBA_COURSE_NAMES.each do |course_name|
          expect(@top_page.race_names(date, course_name)).to be_empty
          expect(@top_page.race_nums(date, course_name)).to be_empty
        end
      end
    end
  end

  describe 'race page' do
    before do
      @race_page = get_race_page(@top_page)
    end

    it 'is displayed' do
      expect(@race_page).to be_displayed
      expect(@race_page).to have_race_name
      expect(@race_page).to have_race_num
      expect(@race_page).to have_race_data
      expect(@race_page).to have_horse_table_link
      expect(@race_page).to have_odds_page_link
    end

    it 'can get horses info' do
      horse_table_page = @race_page.show_horse_table
      horses_info = horse_table_page.horses_info
      expect(horses_info).not_to be_nil
      expect(horses_info[0][:name]).not_to be_nil
      expect(horses_info[0][:race_horse]).not_to be_nil
    end
  end

  describe 'odds page' do
    before do
      race_page = get_race_page(@top_page)
      @odds_page = race_page.go_odds_page
    end

    it 'is displayed' do
      expect(@odds_page).to be_displayed
      # 直前でないと出ない
      # expect(@odds_page).to have_single_odds_table_link
      # expect(@odds_page).to have_single_odds_table
    end
  end
end

def get_race_page(top_page)
  dates = (-3..3).map { |diff| Date.today + diff }
  dates.select! { |date| top_page.date_list.has_content? date.strftime(DATE_PATTERN) }
  NETKEIBA_COURSE_NAMES.each do |course_name|
    # R11のみ公開される場合があるため
    race_page = top_page.go_race_page(dates[0], course_name, 11)
    return race_page unless race_page.nil?
  end
end