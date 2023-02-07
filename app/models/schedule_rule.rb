# frozen_string_literal: true

require 'json'

# Model class for 'schedule_rules' table
class ScheduleRule < ApplicationRecord
  def data
    @data ||= JSON.parse(data_json)
  end

  def summary
    load_data!
    @summary ||= {
      size:     @data.size,
      num_exe:  calculate_number_of_execution,
      duration: sum_of_duration,
    }
  end

  private

  def load_data!
    data
  end

  def calculate_number_of_execution
    @data.inject(0) do |sum, datum|
      sum + (datum['duration'] / datum['interval']).to_i
    end
  end

  def sum_of_duration
    @data.inject(0) do |sum, datum|
      sum + datum['duration']
    end
  end
end
