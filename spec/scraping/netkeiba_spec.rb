# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

COURSE_NAMES = %w[札幌 函館 福島 中山 東京 新潟 中京 京都 阪神 小倉].freeze

RSpec.describe 'Races' do
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

    it 'can select date' do
      dates = (-3..3).map { |diff| Date.today + diff }
      selectable = []
      dates.each do |date|
        date_str = date.strftime('%m月%d日')
        select_data_page = @top_page.select_date(date)
        if @top_page.has_content?(date_str)
          expect(select_data_page).to be_displayed
          selectable.push date_str
        else
          expect(select_data_page).to be nil
        end
      end
      expect(selectable.size).to be > 0
    end
  end

  describe 'race page' do
    before do
      @race_page = nil
      (-3..3).map { |diff| Date.today + diff }.each do |date|
        break unless @top_page.select_date(date).nil?
      end
      COURSE_NAMES.each do |course_name|
        @race_page = @top_page.go_race_page(course_name, 11)
        break unless @race_page.nil?
      end
    end

    it 'is displayed' do
      expect(@race_page).to be_displayed
    end
  end
end
