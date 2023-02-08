# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

RSpec.describe 'ScheduleUmaByCourseJob' do
  before do
    @top_page = instance_double(Netkeiba::TopPage)
    allow(Netkeiba::TopPage).to receive(:new).and_return(@top_page)
    allow(@top_page).to receive(:load).and_return(nil)
    allow(ScheduleUmaByRaceJob).to receive(:perform_later).and_return(true)
  end

  describe 'when race_nums is obtained' do
    before do
      allow(@top_page).to receive(:race_nums).and_return([9, 10])
    end
    let(:date) { Date.parse('2022/12/26') }
    let(:course) { '中京' }

    it '#perform calls ScheduleUmaByRaceJob twice' do
      ScheduleUmaByCourseJob.perform_now(date, course)
      expect(ScheduleUmaByRaceJob).to have_received(:perform_later).twice
    end
  end

  describe 'when race_nums is NOT obtained' do
    before do
      allow(@top_page).to receive(:race_nums).and_return([])
    end
    let(:date) { Date.parse('2022/12/27') }
    let(:course) { '中山' }

    it '#perform raises RuntimeError' do
      exception_expected = 'Cannot fetch race numbers at 中山'
      expect do
        ScheduleUmaByCourseJob.perform_now(date, course)
      end.to raise_error(exception_expected)
    end
  end

  describe 'when non-integer race_nums is obtained' do
    before do
      allow(@top_page).to receive(:race_nums).and_return(%w[first_race 12R])
    end
    let(:date) { Date.parse('2022/12/28') }
    let(:course) { '阪神' }

    it '#perform does NOT call ScheduleUmaByRaceJob' do
      ScheduleUmaByCourseJob.perform_now(date, course)
      expect(ScheduleUmaByRaceJob).not_to have_received(:perform_later)
    end
  end
end
