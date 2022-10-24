# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/api'

RSpec.describe 'ServiceStatuses', type: :request do
  before do
    allow_any_instance_of(Sidekiq::Stats).to receive(:processes_size).and_return(1)
    allow_any_instance_of(Sidekiq::Stats).to receive(:default_queue_latency).and_return(0)
    allow_any_instance_of(Sidekiq::Stats).to receive(:retry_size).and_return(0)
  end

  describe 'GET /service_status' do
    it 'returns OK' do
      get '/service_status'
      expect(response).to have_http_status(200)
      res = JSON.parse(response.body)
      expect(res['app_name']).to     eq 'UMA2'
      expect(res['status']).to       eq 'OK'
      expect(res['details'].keys).to eq %w[db redis sidekiq]
    end

    describe 'when cannot connect database' do
      before { allow(RaceClass).to receive(:first).and_raise('RuntimeError') }

      it 'returns db errors' do
        get '/service_status'
        expect(response).to have_http_status(200)
        res = JSON.parse(response.body)
        expect(res['status']).to eq 'NG'
        expect(res['errors']).to eq ['db: RuntimeError']
      end
    end

    describe 'when cannot connect redis' do
      before { allow_any_instance_of(Redis).to receive(:ping).and_raise('RuntimeError') }

      it 'returns redis errors' do
        get '/service_status'
        expect(response).to have_http_status(200)
        res = JSON.parse(response.body)
        expect(res['status']).to eq 'NG'
        expect(res['errors']).to eq ['redis: RuntimeError']
      end
    end

    describe 'when cannot find sidekiq process' do
      before { allow_any_instance_of(Sidekiq::Stats).to receive(:processes_size).and_return(0) }

      it 'returns sidekiq errors' do
        get '/service_status'
        expect(response).to have_http_status(200)
        res = JSON.parse(response.body)
        expect(res['status']).to eq 'NG'
        expect(res['errors']).to eq ['sidekiq: processes_size 0 is too small']
      end
    end
  end
end
