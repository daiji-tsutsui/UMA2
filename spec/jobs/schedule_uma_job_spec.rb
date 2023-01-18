# frozen_string_literal: true

require 'rails_helper'
require 'netkeiba'

RSpec.describe 'ScheduleUmaJob' do
  before do
    @top_page = instance_double(Netkeiba::TopPage)
    allow(Netkeiba::TopPage).to receive(:new).and_return(@top_page)
    allow(@top_page).to receive(:load).and_return(nil)
    allow(ScheduleUmaByCourseJob).to receive(:perform_later).and_return(true)
  end

  describe 'when course_names is obtained' do
    before do
      allow(@top_page).to receive(:course_names).and_return([
        '1回 中山 1日目',
        '1回 中京 1日目',
      ])
    end

    it '#perform calls ScheduleUmaByCourseJob twice' do
      ScheduleUmaJob.perform_now
      expect(ScheduleUmaByCourseJob).to have_received(:perform_later).twice
    end
  end

  describe 'when course_names is NOT obtained' do
    before do
      allow(@top_page).to receive(:course_names).and_return([])
    end

    it '#perform does NOT call ScheduleUmaByCourseJob' do
      ScheduleUmaJob.perform_now
      expect(ScheduleUmaByCourseJob).not_to have_received(:perform_later)
    end
  end

  describe 'when unexpected course_names is obtained' do
    before do
      allow(@top_page).to receive(:course_names).and_return([
        '高知 1日目',
        'Dubai racing course',
      ])
    end

    it '#perform does NOT call ScheduleUmaByCourseJob' do
      ScheduleUmaJob.perform_now
      expect(ScheduleUmaByCourseJob).not_to have_received(:perform_later)
    end
  end
end
