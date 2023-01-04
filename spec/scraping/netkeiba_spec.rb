# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

COURSE_NAMES = %w[札幌 函館 福島 中山 東京 新潟 中京 京都 阪神 小倉].freeze
DATE_PATTERN = '%-m/%-d'

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

    it 'can get race names for dates displayed' do
      dates = (-3..3).map { |diff| Date.today + diff }
      can_get = []
      dates.each do |date|
        date_str = date.strftime(DATE_PATTERN)
        next unless @top_page.date_list.has_content?(date_str)

        race_names = []
        COURSE_NAMES.each do |course_name|
          race_names = @top_page.race_names(date, course_name)
          unless race_names.empty?
            can_get.push date_str
            break
          end
        end
      end
      expect(can_get.size).to be > 0
    end

    it 'cannot get race names for dates not displayed' do
      dates = (-3..3).map { |diff| Date.today + diff }
      dates.each do |date|
        date_str = date.strftime(DATE_PATTERN)
        next if @top_page.date_list.has_content?(date_str)

        COURSE_NAMES.each do |course_name|
          expect(@top_page.race_names(date, course_name)).to be_empty
        end
      end
    end
  end

  describe 'race page' do
    before do
      @race_page = nil
      dates = (-3..3).map { |diff| Date.today + diff }
      dates.select! { |date| @top_page.date_list.has_content? date.strftime(DATE_PATTERN) }
      COURSE_NAMES.each do |course_name|
        # R11のみ公開される場合があるため
        @race_page = @top_page.go_race_page(dates[0], course_name, 11)
        break unless @race_page.nil?
      end
    end

    it 'is displayed' do
      expect(@race_page).to be_displayed
    end
  end
end
