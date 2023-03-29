# frozen_string_literal: true

# Stats information Controller
class StatsController < ApplicationController
  def index; end

  def api
    test_data = [
      { datetime: '2023/03/29 18:00:00', test1: 100, test2: 200, test3: 400 },
      { datetime: '2023/03/29 19:30:00', test1: 200, test2: 200, test3: 600 },
      { datetime: '2023/03/29 21:00:00', test1: 300, test2: 200, test3: 100 },
      { datetime: '2023/03/29 22:30:00', test1: 200, test2: 200, test3: 200 },
      { datetime: '2023/03/30 01:30:00', test1: 100, test2: 200, test3: 300 },
      { datetime: '2023/03/30 03:00:00', test1: 200, test2: 200, test3: 500 },
      { datetime: '2023/03/30 04:30:00', test1: 300, test2: 200, test3: 800 },
    ]
    render json: test_data
  end
end
