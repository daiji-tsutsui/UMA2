# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require './lib/google'
require './lib/jra'

def test_scraping_google(search_query)
  home = Google::Home.new
  home.load
  home.search_field.set search_query
  result = home.open_search_result

  # pp result.search_result_links
  pp result.title_texts
end

def test_scraping_jra
  top_page = Jra::TopPage.new
  top_page.load

  odds_page = top_page.go_odds
  race_odds_page = odds_page.go_course(Jra::SUNDAY, '阪神')

  single_odds_page = race_odds_page.go_single_odds(Jra::RACE_11)
  pp single_odds_page.uma_name
  pp single_odds_page.tan_odds
  pp single_odds_page.fuku_odds
end

Capybara.default_driver = :selenium_chrome_headless

Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
  test_scraping_google('hello')
  test_scraping_jra
end
