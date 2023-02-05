# frozen_string_literal: true

require 'time'
require 'json'

module Uma2
  # オッズ取得・解析処理のスケジューラ
  class Scheduler
    attr_reader :table

    def initialize(end_time:)
      @end_time = end_time.is_a?(Time) ? end_time : Time.parse(end_time)
      @table = [@end_time]
      plan!
    end

    # 時刻表のそれぞれの時刻に対して処理実行
    def execute!
      yield(@table.shift) while next?
    end

    private

    # 'schedule_rules'のレコードをもとに時刻表を作る
    def plan!
      rule_data = []
      rule = ScheduleRule.find_by(disable: 0)
      begin
        rule_data = JSON.parse(rule.data_json)
      rescue JSON::ParserError
        raise "Eval error, broken schedule_rule record: #{rule.data_json}"
      end

      plan_recursively!(rule_data)
    end

    def plan_recursively!(rule_data)
      # terminate
      return nil if rule_data.empty?

      datum = rule_data.shift
      plan_recursively!(rule_data)

      plan_single_duration!(datum['duration'], datum['interval'])
    end

    def plan_single_duration!(duration, interval)
      next_time = @table.first.clone
      while duration >= interval
        next_time -= interval
        break if next_time < Time.now

        @table.unshift(next_time.clone)
        duration -= interval
      end
    end

    def next?
      # @end_timeは取り出せない
      @table.size > 1
    end
  end
end
