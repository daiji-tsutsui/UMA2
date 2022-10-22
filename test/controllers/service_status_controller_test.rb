# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/api'

class ServiceStatusControllerTest < ActionDispatch::IntegrationTest
  setup do
    Sidekiq::Stats.any_instance.stubs(:processes_size).returns(1)
    Sidekiq::Stats.any_instance.stubs(:default_queue_latency).returns(0)
    Sidekiq::Stats.any_instance.stubs(:retry_size).returns(0)
  end

  teardown do
    Sidekiq::Stats.any_instance.unstub(:processes_size)
    Sidekiq::Stats.any_instance.unstub(:default_queue_latency)
    Sidekiq::Stats.any_instance.unstub(:retry_size)
  end

  test 'GET /service_status returns OK' do
    get '/service_status'
    assert_response :success
    res = JSON.parse(response.body)
    assert_equal('UMA2', res['app_name'])
    assert_equal('OK', res['status'])
    assert_equal(%w[db redis sidekiq], res['details'].keys)
  end

  test 'returns db errors when cannot connect database' do
    RaceClass.stubs(:first).raises
    get '/service_status'
    assert_response :success
    res = JSON.parse(response.body)
    assert_equal('NG', res['status'])
    assert_equal(['db: RuntimeError'], res['errors'])
    RaceClass.unstub(:first)
  end

  test 'returns redis errors when cannot connect redis' do
    Redis.any_instance.stubs(:ping).raises
    get '/service_status'
    assert_response :success
    res = JSON.parse(response.body)
    assert_equal('NG', res['status'])
    assert_equal(['redis: RuntimeError'], res['errors'])
    Redis.any_instance.unstub(:ping)
  end

  test 'returns sidekiq errors when cannot find sidekiq process' do
    Sidekiq::Stats.any_instance.stubs(:processes_size).returns(0)
    get '/service_status'
    assert_response :success
    res = JSON.parse(response.body)
    assert_equal('NG', res['status'])
    assert_equal(['sidekiq: processes_size 0 is too small'], res['errors'])
  end
end
