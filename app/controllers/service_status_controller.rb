# frozen_string_literal: true

require 'sidekiq/api'

# Service Status API Controller
class ServiceStatusController < ApplicationController
  def status
    @details = {}
    @errors = []

    check_status('db') { check_db }
    check_status('redis') { check_redis }
    check_status('sidekiq') { check_sidekiq }

    res = if @errors.empty?
            { app_name: 'UMA2', status: 'OK', details: @details }
          else
            { app_name: 'UMA2', status: 'NG', details: @details, errors: @errors }
          end
    Rails.logger.info "service status: #{res}"
    render json: res
  end

  private

  CHECK_TIMEOUT = 20.seconds
  SIDEKIQ_PROCESSES_LOWER_BOUND = 1
  SIDEKIQ_LATENCY_UPPER_BOUND = 20.seconds
  SIDEKIQ_RETRY_SIZE_UPPER_BOUND = 20

  def check_status(target, &)
    @details[target] ||= {}
    t = Time.current
    Timeout.timeout(CHECK_TIMEOUT, &)
    @details[target][:time] = Time.current - t
  rescue StandardError => e
    @errors.push "#{target}: #{e.message}"
  end

  def check_db
    RaceClass.first
  end

  def check_redis
    Redis.new(Settings.redis.to_h).ping
  end

  def check_sidekiq
    stats = Sidekiq::Stats.new
    @details['sidekiq']['stats'] = stats.instance_variable_get('@stats')

    processes = stats.processes_size
    @errors.push "sidekiq: processes_size #{processes} is too small" if processes < SIDEKIQ_PROCESSES_LOWER_BOUND

    latency = stats.default_queue_latency
    @errors.push "sidekiq: default_queue_latency #{latency} is too large" if latency > SIDEKIQ_LATENCY_UPPER_BOUND

    retry_size = stats.retry_size
    @errors.push "sidekiq: retry_size #{retry_size} is too large" if retry_size > SIDEKIQ_RETRY_SIZE_UPPER_BOUND
  end
end
