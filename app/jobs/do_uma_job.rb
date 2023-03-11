# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'
require 'json'
require 'uma2/optimizer'

# UMAを実行するジョブ
# 適度な回数で一旦最適化を打ち切り，自身をエンキューする

# 初回（is_first: true）のみ下記を実行
# - optimization_processの所有権を更新
# - Uma2::Optimizerのパラメータ数を増加
class DoUmaJob < ApplicationJob
  queue_as :default

  def perform(race_id, odds_history_id, is_first: false)
    # オッズを取得して初めての最適化時，所有権を自分に移す
    occupy_process(race_id, odds_history_id) if is_first

    # 所有権が違ったら終わり
    process = OptimizationProcess.find_by!(race_id: race_id)
    return unless owned?(process, odds_history_id)

    # TODO: 出走時刻を過ぎていたら終わり

    # Optimization process
    odds_list = odds_histories(race_id, odds_history_id)
    optimized_params, is_converged = optimize(process.params, odds_list)

    # 最新のレコードを取り直す
    # TODO: キャッシュから取らないようにしましょう
    process = OptimizationProcess.find_by!(race_id: race_id)
    process.with_lock do
      # せっかく最適化しても，所有権が違ったら更新しない
      return unless owned?(process, odds_history_id)

      process.update!(params_json: optimized_params.to_json)
    end

    if is_converged
      Rails.logger.info('Optimizer converges!!')
    else
      DoUmaJob.perform_later(race_id, odds_history_id)
    end
  end

  private

  # optimization_processのUPSERT
  def occupy_process(race_id, odds_history_id)
    Retryable.retryable(on: [ActiveRecord::RecordNotUnique], tries: 5) do
      OptimizationProcess.upsert_all([{
        race_id:              race_id,
        last_odds_history_id: odds_history_id,
      }], unique_by: 'race_id')
    end
  end

  def owned?(process, odds_history_id)
    process.last_odds_history_id == odds_history_id
  end

  def optimize(params, odds_list)
    optimizer = Uma2::Optimizer.new(params: params)
    optimizer.add_odds(odds_list)
    optimizer.run(Settings.uma2.iteration)
    is_converged = optimizer.converges?
    [optimizer.parameter, is_converged]
  end

  def odds_histories(race_id, last_odds_history_id)
    OddsHistory.where(race_id: race_id)
               .where(id: ..last_odds_history_id)
               .order(id: :asc)
               .all.map(&:data)
  end
end
