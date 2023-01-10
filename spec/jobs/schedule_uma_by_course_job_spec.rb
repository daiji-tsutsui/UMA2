# frozen_string_literal: true

require 'rails_helper'
require 'schedule_uma_job'
require 'netkeiba'

JOB_TEST_DATE   = Date.today
JOB_TEST_COURSE = '中山'

RSpec.describe 'ScheduleUmaByCourseJob' do
  before do
    @top_page = instance_double(Netkeiba::TopPage)
    allow(Netkeiba::TopPage).to receive(:new).and_return(@top_page)
    allow(@top_page).to receive(:load).and_return(nil)
    allow(ScheduleUmaByRaceJob).to receive(:perform_later).and_return(true)
  end

  describe 'when race_nums is obtained' do
    before do
      allow(@top_page).to receive(:race_nums).and_return([1, 2])
    end

    it '#perform calls ScheduleUmaByRaceJob twice' do
      ScheduleUmaByCourseJob.perform_now(JOB_TEST_DATE, JOB_TEST_COURSE)
      expect(ScheduleUmaByRaceJob).to have_received(:perform_later).twice
    end
  end

  describe 'when race_nums is NOT obtained' do
    before do
      allow(@top_page).to receive(:race_nums).and_return([])
    end

    it '#perform raises RuntimeError' do
      exception_expected = "Cannot fetch race numbers at #{JOB_TEST_COURSE}"
      expect do
        ScheduleUmaByCourseJob.perform_now(JOB_TEST_DATE, JOB_TEST_COURSE)
      end.to raise_error(exception_expected)
    end
  end

  describe 'when non-integer race_nums is obtained' do
    before do
      allow(@top_page).to receive(:race_nums).and_return(%w[first_race 12R])
    end

    it '#perform does NOT call ScheduleUmaByRaceJob' do
      ScheduleUmaByCourseJob.perform_now(JOB_TEST_DATE, JOB_TEST_COURSE)
      expect(ScheduleUmaByRaceJob).not_to have_received(:perform_later)
    end
  end
end
