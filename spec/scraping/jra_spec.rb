# frozen_string_literal: true

require 'rails_helper'
require 'jra'

COURSE_NAMES = %w[札幌 函館 福島 中山 東京 新潟 中京 京都 阪神 小倉].freeze
ODDS_PAGE_MESSAGE_NO_RACE = '今週のオッズは未発表です'

RSpec.describe 'Jra' do
  before do
    @top_page = Jra::TopPage.new
    @top_page.load
  end

  describe 'top page' do
    it 'is displayed' do
      expect(@top_page).to be_displayed
      expect(@top_page).to have_menu_items
    end
  end

  describe 'odds page' do
    before { @odds_page = @top_page.go_odds_page }

    it 'is displayed' do
      expect(@odds_page).to be_displayed
      if @odds_page.no_races?
        expect(@odds_page.msg_absent).to have_content ODDS_PAGE_MESSAGE_NO_RACE
      else
        expect(@odds_page).to have_this_week
      end
    end

    it 'can select date' do
      skip if @odds_page.no_races?

      dates = (-3..3).map { |diff| Date.today + diff }
      selectable = []
      dates.each do |date|
        date_str = date.strftime('%-m月%-d日')
        course_table = @odds_page.select_date(date)
        if @odds_page.this_week.has_content?(date_str)
          expect(course_table).not_to be nil
          selectable.push date_str
        else
          expect(course_table).to be nil
        end
      end
      expect(selectable.size).to be > 0
    end
  end

  describe 'race_odds page' do
    before { @odds_page = @top_page.go_odds_page }

    it 'is displayed' do
      skip if @odds_page.no_races?

      dates = (-3..3).map { |diff| Date.today + diff }
      race_odds_page = nil
      dates.each do |date|
        date_str = date.strftime('%-m月%-d日')
        next unless @odds_page.this_week.has_content?(date_str)

        COURSE_NAMES.each do |course_name|
          next unless @odds_page.this_week.has_content?(course_name)

          race_odds_page = @odds_page.go_race_odds_page(date, course_name)
          break
        end
        break
      end
      expect(race_odds_page).to be_displayed
      expect(race_odds_page).to have_races
    end
  end
end
