# frozen_string_literal: true

require 'rails_helper'
require 'jra'

Capybara.default_driver = :selenium_chrome_headless

RSpec.describe 'Races' do
  before do
    @top_page = Jra::TopPage.new
    @top_page.load
  end

  describe 'top page' do
    it 'accepts GET' do
      expect(@top_page).to be_displayed
      expect(@top_page).to have_menu_items
    end
  end
end
