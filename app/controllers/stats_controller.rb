# frozen_string_literal: true

# Stats information Controller
class StatsController < ApplicationController
  def index; end

  def api
    @races = Race.search(search_params)
    Rails.logger.debug("Daiji log: #{@races.map(&:attributes)}")

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

  private

  def search_params
    build_duration
    params.permit(:course, :number, race_class: [])
          .merge(duration: @start..@end)
  end

  def build_duration
    build_duration_start
    build_duration_end
    if @end <= @start
      @start = @end - 1.month
    end
  end

  def build_duration_start
    @start = Date.parse(params[:date_start])
  rescue
    @start = Date.today - 1.month
  end

  def build_duration_end
    @end = Date.parse(params[:date_end])
  rescue
    @end = Date.today
  end
end
