# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

RSpec.describe 'FetchResultJob' do
  before do
    @top_page = instance_double(Netkeiba::TopPage)
    @result_page = instance_double(Netkeiba::ResultPage)
    @odds_page = instance_double(Netkeiba::OddsPage)
    allow(Netkeiba::TopPage).to receive(:new).and_return(@top_page)
    allow(@top_page).to receive(:load).and_return(nil)
    allow(@top_page).to receive(:go_race_page).and_return(@result_page)
    allow(@result_page).to receive(:go_odds_page).and_return(@odds_page)
    @race_id = Race.find_by(name: 'Test1').id
  end
  subject { FetchResultJob.perform_now(@race_id) }

  describe 'when both result_info and final_odds_info are obtained' do
    before do
      allow(@result_page).to receive(:result_info).and_return(result_data)
      allow(@odds_page).to receive(:single_odds_for_result).and_return(odds_data)
    end

    it '#perform inserts 1 RaceResult record' do
      expect { subject }.to change { RaceResult.count }.by(1)
      result = RaceResult.find_by(race_id: @race_id)
      expect(result.data[0]['order']).to  eq 1
      expect(result.data[0]['number']).to eq 1
      expect(result.odds).to              eq [2.0, 2.0, 4.0]
    end

    it '#perform updates RaceHorse weight' do
      subject
      horse = Horse.find_by(name: 'タニノギムレット')
      race_horse = RaceHorse.find_by(race_id: @race_id, horse_id: horse.id)
      expect(race_horse.weight).to eq '492'
    end
  end

  describe 'when result_info is NOT obtained' do
    before do
      allow(@result_page).to receive(:result_info).and_return([])
      allow(@odds_page).to receive(:single_odds_for_result).and_return(odds_data)
    end

    it '#perform raises RuntimeError' do
      exception_expected = 'Cannot fetch result info at 札幌 11R'
      expect { subject }.to raise_error(exception_expected)
    end
  end

  describe 'when final_odds_info is NOT obtained' do
    before do
      allow(@result_page).to receive(:result_info).and_return(result_data)
      allow(@odds_page).to receive(:single_odds_for_result).and_return([])
    end

    it '#perform raises RuntimeError' do
      exception_expected = 'Cannot fetch final odds at 札幌 11R'
      expect { subject }.to raise_error(exception_expected)
    end
  end

  private

  def result_data
    [
      { order: 1, name: 'ハリボテエレジー', weight: '500' },
      { order: 2, name: 'アシタハレルカナ', weight: '485' },
      { order: 3, name: 'タニノギムレット', weight: '492' },
    ]
  end

  def odds_data
    ['2.0', '2.0', '4.0']
  end
end
