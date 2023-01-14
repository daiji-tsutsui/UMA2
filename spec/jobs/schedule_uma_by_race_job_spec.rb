# frozen_string_literal: true

require 'rails_helper'
require 'schedule_uma_job'
require 'netkeiba'

SCHEDULE_UMA_BY_RACE_JOB_COURSE_NAKAYAMA = 4
SCHEDULE_UMA_BY_RACE_JOB_RACE_CLASS_G1 = 1

RSpec.describe 'ScheduleUmaByRaceJob' do
  before do
    @top_page = instance_double(Netkeiba::TopPage)
    @race_page = instance_double(Netkeiba::RacePage)
    allow(Netkeiba::TopPage).to receive(:new).and_return(@top_page)
    allow(@top_page).to receive(:load).and_return(nil)
    allow(@top_page).to receive(:go_race_page).and_return(@race_page)
    allow(FetchOddsAndDoUmaJob).to receive(:perform_later).and_return(true)
  end

  describe 'perform' do
    before do
      allow(@race_page).to receive(:race_info).and_return({
        name:          'テスト大賞典',
        number:        11,
        race_class:    'G1',
        weather:       '',
        distance:      2000,
        course_type:   '芝',
        starting_time: '15:35',
      })
    end

    it '#inserts a Race record' do
      date = Date.parse('2023/01/14')
      ScheduleUmaByRaceJob.perform_now(date, '中山', 11)
      race = Race.find_by(name: 'テスト大賞典')
      expect(race[:name]).to          eq 'テスト大賞典'
      expect(race[:number]).to        eq 11
      expect(race[:race_date_id]).to  eq 2
      expect(race[:course_id]).to     eq SCHEDULE_UMA_BY_RACE_JOB_COURSE_NAKAYAMA
      expect(race[:race_class_id]).to eq SCHEDULE_UMA_BY_RACE_JOB_RACE_CLASS_G1
      expect(race[:distance]).to      eq 2000
      expect(race[:course_type]).to   eq '芝'
      expect(race[:starting_time]).to eq '15:35'
    end
  end

  # describe 'when race_nums is NOT obtained' do
  #   before do
  #     allow(@top_page).to receive(:race_nums).and_return([])
  #   end

  #   it '#perform raises RuntimeError' do
  #     exception_expected = "Cannot fetch race numbers at #{JOB_TEST_COURSE}"
  #     expect {
  #       ScheduleUmaByCourseJob.perform_now(JOB_TEST_DATE, JOB_TEST_COURSE)
  #     }.to raise_error(exception_expected)
  #   end
  # end

  # describe 'when non-integer race_nums is obtained' do
  #   before do
  #     allow(@top_page).to receive(:race_nums).and_return(%w[first_race 12R])
  #   end

  #   it '#perform does NOT call ScheduleUmaByRaceJob' do
  #     ScheduleUmaByCourseJob.perform_now(JOB_TEST_DATE, JOB_TEST_COURSE)
  #     expect(ScheduleUmaByRaceJob).not_to have_received(:perform_later)
  #   end
  # end
end
