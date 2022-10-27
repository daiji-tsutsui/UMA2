# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Netkeiba
  # netkeibaのレース情報ページ
  class RacePage < SitePrism::Page
    set_url 'https://race.netkeiba.com/race/shutuba.html{?query*}'
  end
end
