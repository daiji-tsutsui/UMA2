# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DoUmaJob' do
  before do
    allow(DoUmaJob).to receive(:perform_later).and_return(true)
  end

  describe 'when is the first time' do
    before do
      @race_id = Race.find_by(name: 'Test1').id
      @odds_history_id = OddsHistory.create(latest_odds_data).id
    end
    subject { DoUmaJob.perform_now(@race_id, @odds_history_id, is_first: true) }

    it '#perform inserts a OptimizationProcess record' do
      expect { subject }.to change { OptimizationProcess.count }.by(1)
      process = OptimizationProcess.find_by(race_id: @race_id)
      expect(process.last_odds_history_id).to eq @odds_history_id
    end

    it '#perform creates a set of optimized parameters' do
      subject
      process = OptimizationProcess.find_by(race_id: @race_id)
      expect(process.params).not_to be_nil
      expect(process.params).to include('a', 'b', 't')
    end

    it '#perform calls another one DoUmaJob' do
      subject
      expect(DoUmaJob).to have_received(:perform_later).once
    end

    describe 'when OptimizationProcess already exists' do
      before do
        OptimizationProcess.create({
          race_id: @race_id,
          last_odds_history_id: 1, # != @odds_history_id
          params_json: params_json_data,
        })
      end

      it '#perform updates a OptimizationProcess record' do
        expect { subject }.not_to(change { OptimizationProcess.count })
        process = OptimizationProcess.find_by(race_id: @race_id)
        expect(process.last_odds_history_id).to eq @odds_history_id
      end

      it '#perform updates a set of optimized parameters' do
        subject
        process = OptimizationProcess.find_by(race_id: @race_id)
        expect(process.params_json).not_to eq params_json_data
      end

      it '#perform calls another one DoUmaJob' do
        subject
        expect(DoUmaJob).to have_received(:perform_later).once
      end
    end
  end

  describe 'when is NOT the first time' do
    before do
      @race_id = Race.find_by(name: 'Test1').id
      @odds_history_id = OddsHistory.create(latest_odds_data).id
      OptimizationProcess.create({
        race_id: @race_id,
        last_odds_history_id: @odds_history_id,
        params_json: params_json_data,
      })
    end
    subject { DoUmaJob.perform_now(@race_id, odds_history_id, is_first: false) }
    let(:odds_history_id) { @odds_history_id }

    it '#perform updates a set of optimized parameters' do
      subject
      process = OptimizationProcess.find_by(race_id: @race_id)
      expect(process.params_json).not_to eq params_json_data
    end

    it '#perform calls another one DoUmaJob' do
      subject
      expect(DoUmaJob).to have_received(:perform_later).once
    end

    describe 'if is NOT the owner of optimization process' do
      let(:odds_history_id) { 2 } # != @odds_history_id

      it '#perform do nothing' do
        expect { subject }.not_to(change do
          OptimizationProcess.find_by(race_id: @race_id).updated_at
        end)
        expect(DoUmaJob).not_to have_received(:perform_later)
      end
    end

    describe 'if the owner changes in optimization process' do
      before do
        # optimizer.run の最中に，別workerに所有権を奪われたケース
        allow_any_instance_of(Uma2::Optimizer).to receive(:run).and_return(process_owner_is_changed(@race_id))
      end

      it '#perform do nothing' do
        expect { subject }.not_to(change do
          OptimizationProcess.find_by(race_id: @race_id).updated_at
        end)
        expect(DoUmaJob).not_to have_received(:perform_later)
      end
    end
  end

  def latest_odds_data
    {
      race_id:    1,
      data_json:  '[20.0,5.0,1.1]',
      created_at: '2023-02-11 14:45:00',
    }
  end

  def params_json_data
    '{"a":[0.8,0.2],"b":[1.0,1.0],"t":[0.02,0.23,0.75]}'
  end

  def process_owner_is_changed(race_id)
    new_odds_history_id = OddsHistory.create(latest_odds_data).id
    process = OptimizationProcess.find_by(race_id: race_id)
    process.update(last_odds_history_id: new_odds_history_id)
  end
end
