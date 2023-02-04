# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

# SCHEDULE_UMA_BY_RACE_JOB_COURSE_TOKYO = 5
# SCHEDULE_UMA_BY_RACE_JOB_RACE_CLASS_G1 = 1

RSpec.describe 'ScheduleUmaWithRegisteringHorsesJob' do
  before do
    @top_page = instance_double(Netkeiba::TopPage)
    @race_page = instance_double(Netkeiba::RacePage)
    allow(Netkeiba::TopPage).to receive(:new).and_return(@top_page)
    allow(@top_page).to receive(:load).and_return(nil)
    allow(@top_page).to receive(:go_race_page).and_return(@race_page)
    allow(@race_page).to receive(:show_horse_table).and_return(@race_page)
    allow(FetchOddsAndDoUmaJob).to receive(:perform_later).and_return(true)
  end

  describe 'when horses_info is obtained' do
    before do
      allow(@race_page).to receive(:horses_info).and_return(test_data)
      @race_id = Race.find_by(name: 'Test1').id
    end

    it '#perform inserts 3 Horse records' do
      expect do
        ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      end.to change { Horse.count }.by(3)
      horse = Horse.find_by(name: 'ソールオリエンス')
      expect(horse).not_to be nil
      expect(horse.last_race_horse_id).not_to be nil
    end

    it '#perform inserts 3 RaceHorse records' do
      expect do
        ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      end.to change { RaceHorse.count }.by(3)
      horse = Horse.find_by(name: 'セブンマジシャン')
      race_horse = RaceHorse.find_by(race_id: @race_id, horse_id: horse.id)
      expect(race_horse.number).to eq 7
      expect(race_horse.sexage).to eq '牡3'
      expect(race_horse.jockey).to eq 'ルメール'
    end

    it '#perform calls FetchOddsAndDoUmaJob once' do
      ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      expect(FetchOddsAndDoUmaJob).to have_received(:perform_later).once
    end

    it '#perform AGAIN does NOT change Horse records' do
      ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      expect do
        ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      end.not_to(change { Horse.count })
    end

    it '#perform AGAIN does NOT call FetchOddsAndDoUmaJob' do
      ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id) # Do again
      expect(FetchOddsAndDoUmaJob).to have_received(:perform_later).once
    end
  end

  describe 'when horses_info is NOT obtained' do
    before do
      allow(@race_page).to receive(:horses_info).and_return([])
      @race_id = Race.find_by(name: 'Test2').id
    end

    it '#perform raises RuntimeError' do
      # 例外メッセージによるfetch_race_infoの動作保証も兼ねる
      exception_expected = 'Cannot fetch horses at 中山 3R'
      expect do
        ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      end.to raise_error(exception_expected)
    end
  end

  describe 'when horse_table_page CANNOT be fetched' do
    before do
      allow(@race_page).to receive(:show_horse_table).and_return(nil)
      @race_id = Race.find_by(name: 'Test1').id
    end

    it '#perform raises RuntimeError' do
      # 例外メッセージによるfetch_race_infoの動作保証も兼ねる
      exception_expected = 'Cannot get horse table: 札幌 - 11R'
      expect do
        ScheduleUmaWithRegisteringHorsesJob.perform_now(@race_id)
      end.to raise_error(exception_expected)
    end
  end

  private

  def test_data
    [
      {
        name: 'ソールオリエンス',
        race_horse: {
          frame:  4,
          number: 4,
          sexage: '牡3',
          jockey: '横山武',
          weight: 462,
        },
      },
      {
        name: 'オメガリッチマン',
        race_horse: {
          frame:  3,
          number: 3,
          sexage: '牡3',
          jockey: '石川',
          weight: 434,
        },
      },
      {
        name: 'セブンマジシャン',
        race_horse: {
          frame:  7,
          number: 7,
          sexage: '牡3',
          jockey: 'ルメール',
          weight: 480,
        },
      },
    ]
  end
end
