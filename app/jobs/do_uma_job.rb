# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'
require 'json'
# require 'uma2/optimizer'

# UMAを実行するジョブ
# 適度な回数で一旦最適化を打ち切り，自身をエンキューする

# 初回（is_first: true）のみ下記を実行
# - optimization_processの所有権を更新
# - Uma2::Optimizerのパラメータ数を増加
class DoUmaJob < ApplicationJob
  queue_as :default

  OPTIMIZER_ITERATION = 100

  def perform(race_id, odds_history_id, is_first: false)
    # # optimization_processのUPSERT
    # if is_first
    #   Retryable.retryable(on: [ActiveRecord::RecordNotUnique], tries: 5) do
    #     OptimizationProcess.upsert_all([{
    #       race_id:              race_id,
    #       last_odds_history_id: odds_history_id,
    #     }], unique_by: 'race_id')
    #   end
    # end

    # process = OptimizationProcess.find_by(race_id: race_id)
    # # 所有権が違ったら終わり
    # return unless process.last_odds_history_id == odds_history_id

    # # Optimization process
    # optimizer = Uma2::Optimizer.new(params: process.params)
    # odds_histories = OddsHistory.where(race_id: race_id)
    #                             .where(id: ...odds_history_id)
    #                             .all.map(&:data)
    # optimizer.add_odds(odds_histories)
    # optimizer.run(OPTIMIZER_ITERATION)

    # process = OptimizationProcess.find_by(race_id: race_id)
    # process.with_lock do
    #   # 所有権が違ったら更新しない
    #   return unless process.last_odds_history_id == odds_history_id
    #   process.update!(params: optimizer.params.to_json)
    # end

    # DoUmaJob.perform_later(race_id, odds_history_id)
  end
end
