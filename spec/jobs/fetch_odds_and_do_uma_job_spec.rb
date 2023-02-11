# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

RSpec.describe 'FetchOddsAndDoUmaJob' do
  before do
    @top_page = instance_double(Netkeiba::TopPage)
    @race_page = instance_double(Netkeiba::RacePage)
    @odds_page = instance_double(Netkeiba::OddsPage)
    allow(Netkeiba::TopPage).to receive(:new).and_return(@top_page)
    allow(@top_page).to receive(:load).and_return(nil)
    allow(@top_page).to receive(:go_race_page).and_return(@race_page)
    allow(@race_page).to receive(:go_odds_page).and_return(@odds_page)
    allow(DoUmaJob).to receive(:perform_later).and_return(true)
  end

  describe 'when odds_info is obtained' do
    before do
      allow(@odds_page).to receive(:single_odds).and_return(test_data1)
      @race_id = Race.find_by(name: 'Test2').id
    end

    it '#perform inserts 1 OddsHistory record' do
      expect do
        FetchOddsAndDoUmaJob.perform_now(@race_id)
      end.to change { OddsHistory.count }.by(1)
      odds = OddsHistory.find_by(race_id: @race_id)
      expect(odds).not_to be nil
      expect(odds.data).to eq [2.0, 2.7, 4.0, 8.0]
    end

    it '#perform calls DoUmaJob once' do
      FetchOddsAndDoUmaJob.perform_now(@race_id)
      expect(DoUmaJob).to have_received(:perform_later).once
    end
  end

  describe 'when odds_info is NOT obtained' do
    before do
      allow(@odds_page).to receive(:single_odds).and_return([])
      @race_id = Race.find_by(name: 'Test1').id
    end

    it '#perform raises RuntimeError' do
      exception_expected = 'Cannot fetch odds at 札幌 11R'
      expect do
        FetchOddsAndDoUmaJob.perform_now(@race_id)
      end.to raise_error(exception_expected)
    end
  end

  describe 'when odds_info contains missing data' do
    before do
      allow(@odds_page).to receive(:single_odds).and_return(test_data2)
      @race_id = Race.find_by(name: 'Test2').id
    end

    it '#perform inserts 1 OddsHistory record' do
      expect do
        FetchOddsAndDoUmaJob.perform_now(@race_id)
      end.to change { OddsHistory.count }.by(1)
      odds = OddsHistory.find_by(race_id: @race_id)
      expect(odds).not_to be nil
      expect(odds.data).to eq [1.6, 0.0, 3.2, 3.2, 0.0, 0.0]
    end
  end

  private

  def test_data1
    ['2.0', '2.7', '4.0', '8.0']
  end

  def test_data2
    ['1.6', '', '3.2', '3.2', '欠場', nil]
  end
end
