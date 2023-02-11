# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ScheduleRules', type: :request do
  describe 'GET /schedules' do
    subject { get schedule_rules_path }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'renders list of schedule rules' do
      is_expected.to render_template('_link_list')
      expect(response.body).to include('項数: 4')
      expect(response.body).to include('実行総数: 17')
      expect(response.body).to include('総期間: 4500')
    end

    it 'renders clauses of a target schedule rule' do
      subject
      # table headers
      expect(response.body).to include('適用期間')
      expect(response.body).to include('実行間隔')
      # table rows
      expect(response.body).to include('1800')
      expect(response.body).to include('300')
    end

    it 'renders a schedule example' do
      is_expected.to render_template('_example')
      expect(response.body).to include('Schedule example')
      expect(response.body).to include('14:20:00')
      expect(response.body).to include('15:33:00')
    end
  end

  describe 'GET /schedules/:id' do
    subject { get schedule_rule_path(1) }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'renders list of schedule rules' do
      is_expected.to render_template('_link_list')
      expect(response.body).to include('項数: 4')
      expect(response.body).to include('実行総数: 17')
      expect(response.body).to include('総期間: 4500')
    end

    it 'renders clauses of a target schedule rule' do
      is_expected.to render_template('_form')
      # table headers
      expect(response.body).to include('適用期間')
      expect(response.body).to include('実行間隔')
      # table rows
      expect(response.body).to include('1200')
      expect(response.body).to include('600')
    end

    it 'renders a schedule example' do
      is_expected.to render_template('_example')
      expect(response.body).to include('Schedule example')
      expect(response.body).to include('14:30:00')
      expect(response.body).to include('15:31:00')
    end
  end

  describe 'POST /schedules/:id' do
    subject { post schedule_rule_path(schedule_rule_id), params: params, headers: headers }

    describe 'with proper parameters' do
      let(:schedule_rule_id) { 2 }
      let(:params) { { duration: %w[3600 2400], interval: %w[300 200] } }
      let(:headers) { {} }

      it 'should redirect to "/schedules"' do
        is_expected.to eq 302
        is_expected.to redirect_to schedule_rules_path
      end

      it 'changes a target record' do
        subject
        rule = ScheduleRule.find(schedule_rule_id)
        expect(rule.disable).to eq 0
        expect(rule.data.size).to eq 2
        expect(rule.data[0]).to eq({ 'duration' => 3600, 'interval' => 300 })
        expect(rule.data[1]).to eq({ 'duration' => 2400, 'interval' => 200 })
      end
    end

    describe 'with improper parameters' do
      let(:schedule_rule_id) { 2 }
      let(:params) { { duration: ['', '2400'], interval: %w[300 200] } }
      let(:headers) { { 'HTTP_REFERER' => '/from_there' } }

      it 'should redirect back' do
        is_expected.to eq 302
        is_expected.to redirect_to '/from_there'
      end

      it 'does NOT change a target record' do
        subject
        rule = ScheduleRule.find(schedule_rule_id)
        expect(rule.disable).to eq 1
        expect(rule.data.size).to eq 1
        expect(rule.data[0]).to eq({ 'duration' => 1000, 'interval' => 100 })
      end
    end

    describe 'with some problems on database' do
      let(:schedule_rule_id) { 2 }
      let(:params) { { duration: %w[3600 2400], interval: %w[300 200] } }
      let(:headers) { { 'HTTP_REFERER' => '/from_there' } }

      before { allow_any_instance_of(ScheduleRule).to receive(:update!).and_raise(ActiveRecord::ActiveRecordError) }

      it 'should redirect back' do
        is_expected.to eq 302
        is_expected.to redirect_to '/from_there'
      end

      it 'does NOT change a target record' do
        subject
        rule = ScheduleRule.find(schedule_rule_id)
        expect(rule.disable).to eq 1
        expect(rule.data.size).to eq 1
        expect(rule.data[0]).to eq({ 'duration' => 1000, 'interval' => 100 })
      end
    end
  end

  describe 'GET /schedules/new' do
    subject { get new_schedule_path }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'renders form template' do
      is_expected.to render_template('_form')
    end
  end

  describe 'POST /schedules/new' do
    subject { post new_schedule_path, params: params, headers: headers }

    describe 'with proper parameters' do
      let(:params) { { duration: %w[3000 1200], interval: %w[600 100] } }
      let(:headers) { {} }

      it 'should redirect to "/schedules"' do
        is_expected.to eq 302
        is_expected.to redirect_to schedule_rules_path
      end

      it 'create a record' do
        expect { subject }.to change { ScheduleRule.count }.by(1)
        rule = ScheduleRule.last
        expect(rule.disable).to eq 0
        expect(rule.data.size).to eq 2
        expect(rule.data[0]).to eq({ 'duration' => 3000, 'interval' => 600 })
        expect(rule.data[1]).to eq({ 'duration' => 1200, 'interval' => 100 })
      end
    end

    describe 'with improper parameters' do
      let(:params) { { duration: %w[1000], interval: %w[200 100] } }
      let(:headers) { { 'HTTP_REFERER' => '/from_there' } }

      it 'should redirect back ' do
        is_expected.to eq 302
        is_expected.to redirect_to '/from_there'
      end

      it 'does NOT create any record' do
        expect { subject }.not_to(change { ScheduleRule.count })
      end
    end

    describe 'with some problems on database' do
      let(:params) { { duration: %w[3000 1200], interval: %w[600 100] } }
      let(:headers) { { 'HTTP_REFERER' => '/from_there' } }

      before { allow(ScheduleRule).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError) }

      it 'should redirect back' do
        is_expected.to eq 302
        is_expected.to redirect_to '/from_there'
      end

      it 'does NOT create any record' do
        expect { subject }.not_to(change { ScheduleRule.count })
      end
    end
  end
end
