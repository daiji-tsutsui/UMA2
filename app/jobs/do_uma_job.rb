# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'
require 'netkeiba'

# UMAを実行するジョブ
# 適度な回数で一旦最適化を打ち切り，自身をエンキューする

# 初回（is_first: true）のみ下記を実行
# - optimization_processの所有権を更新
# - Uma2::Optimizerのパラメータ数を増加
class DoUmaJob < ApplicationJob
  queue_as :default

  def perform(race_id, odds_history_id, is_first:)
    # optimization_processのUPSERT

    # Optimization process

    # DoUmaJob.perform_later(race_id, odds_history_id, is_first: false)
  end
end
