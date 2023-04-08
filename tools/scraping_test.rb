# frozen_string_literal: true

# 開発中のNetkeiba::RacePageの動作確認用
# GitHubには入れない

$LOAD_PATH.push '/home/daiji/work/ruby/UMA2/lib'
require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'
require 'active_support/all'

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1366,720')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless
Capybara.default_driver = :chrome_headless

# main procedure
date = Date.parse('2023-04-02')
course_name = '中山'
race_num = 11

result_info = []
final_odds_info = []
Capybara::Session.new(:selenium_chrome_headless).tap do |_session|
  top_page = Netkeiba::TopPage.new
  top_page.load
  result_page = top_page.go_race_page(date, course_name, race_num)
  raise "Cannot go to Netkeiba result page: #{course_name} - #{race_num}R" if result_page.nil?

  result_info = result_page.result_info
  # レース結果が取れていないのはおかしい
  raise "Cannot fetch result info at #{course_name} #{race_num}R" if result_info.empty?

  final_odds_info = result_page.go_odds_page.single_odds_for_result
  # オッズ情報が取れていないのはおかしい
  raise "Cannot fetch final odds at #{course_name} #{race_num}R" if final_odds_info.blank?
end

pp result_info
pp final_odds_info
