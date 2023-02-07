# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ScheduleRules', type: :request do
  describe 'GET /schedules' do
    before { get schedule_rules_path }

    it 'should response success' do
      expect(response).to have_http_status(200)
    end

    it 'renders list of schedule rules' do
      expect(response.body).to include('項数: 4')
      expect(response.body).to include('実行総数: 17')
      expect(response.body).to include('総期間: 4500')
      expect(response).to render_template('_link_list')
    end

    it 'renders clauses of a target schedule rule' do
      # table headers
      expect(response.body).to include('適用期間')
      expect(response.body).to include('実行間隔')
      # table rows
      expect(response.body).to include('1800')
      expect(response.body).to include('300')
    end
  end

  describe 'GET /schedules/:id' do
    before { get schedule_rule_path(1) }

    it 'should response success' do
      expect(response).to have_http_status(200)
    end

    it 'renders list of schedule rules' do
      expect(response.body).to include('項数: 4')
      expect(response.body).to include('実行総数: 17')
      expect(response.body).to include('総期間: 4500')
      expect(response).to render_template('_link_list')
    end

    it 'renders clauses of a target schedule rule' do
      # table headers
      expect(response.body).to include('適用期間')
      expect(response.body).to include('実行間隔')
      # table rows
      expect(response.body).to include('1200')
      expect(response.body).to include('600')
      expect(response).to render_template('_form')
    end
  end

  describe 'GET /schedules/new' do
    before { get new_schedule_path }

    it 'should response success' do
      expect(response).to have_http_status(200)
    end

    it 'renders form template' do
      expect(response).to render_template('_form')
    end
  end
end
