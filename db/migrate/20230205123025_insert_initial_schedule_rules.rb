require 'json'

class InsertInitialScheduleRules < ActiveRecord::Migration[7.0]
  def change
    rule_data_json = [
      { duration: 30 * 60, interval: 10 * 60 },
      { duration: 20 * 60, interval: 5 * 60 },
      { duration: 15 * 60, interval: 3 * 60 },
      { duration: 10 * 60, interval: 2 * 60 },
    ].to_json
    ScheduleRule.create(data_json: rule_data_json)
  end
end
