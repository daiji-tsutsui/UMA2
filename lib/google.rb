# frozen_string_literal: true

require 'site_prism'
require 'capybara/dsl'

module Google
  # Google home page
  class Home < SitePrism::Page
    set_url 'https://www.google.com'

    element :search_field, "input[name='q']"
    elements :search_buttons, "input[name='btnK']"

    def open_search_result
      search_buttons.each do |button|
        # なぜか見えない「Google検索」ボタンがあることがあるので
        button.click if button.visible?
      end
      # 次のページを返す
      SearchResults.new
    end
  end

  # Google search result page
  class SearchResults < SitePrism::Page
    set_url_matcher(%r{google.com/search\?.*})

    elements :links, 'a'
    elements :titles, 'h3'

    def search_result_links
      links.map { |lk| lk['href'] }
    end

    def title_texts
      titles.map(&:text)
    end
  end
end
