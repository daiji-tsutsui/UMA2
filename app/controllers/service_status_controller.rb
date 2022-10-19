# frozen_string_literal: true

# Service Status API Controller
class ServiceStatusController < ApplicationController
  def status
    @details = {}
    @errors = []

    check_status('db') { check_db }

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
end
