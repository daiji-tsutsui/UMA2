# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Uma2::Scheduler' do
  describe 'when end_time is given' do
    before do
      @scheduler = Uma2::Scheduler.new(end_time: end_time)
      allow(MockJob).to receive(:perform_later).and_return(true)
    end
    let(:end_time) { Time.now + 10_800 }

    it '#new creates a time table' do
      expect(@scheduler.table.is_a?(Array)).to   be_truthy
      expect(@scheduler.table.size).to           eq 18
      expect(@scheduler.table[0].is_a?(Time)).to be_truthy
      expect(@scheduler.table[0]).to             be > Time.now
      expect(@scheduler.table[-1]).to            eq end_time
    end

    it '#execute do action for each time in table' do
      @scheduler.execute! do |t|
        MockJob.set(wait_until: t).perform_later
      end
      expect(MockJob).to have_received(:perform_later).exactly(17).times
      expect(MockJob.wait_until).to be < end_time
    end

    it '#execute_after do action for each time in table' do
      @scheduler.execute_after do |t|
        MockJob.set(wait_until: t).perform_later
      end
      expect(MockJob).to have_received(:perform_later).once
      expect(MockJob.wait_until).to eq end_time + 30.minutes
    end
  end

  describe 'when end_time is NOT given' do
    it '#new raises ArgumentError' do
      expect { Uma2::Scheduler.new }.to raise_error(ArgumentError)
    end
  end

  class MockJob
    def self.set(wait_until: nil)
      @wait_until = wait_until
      MockJob
    end

    def self.perform_later
      # nothing
    end

    def self.wait_until
      @wait_until
    end
  end
end
