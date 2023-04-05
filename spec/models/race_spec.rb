# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Race' do
  describe '#search' do
    subject { Race.search(search_params).map(&:id) }

    context 'by name' do
      let(:search_params) { { name: 'Test' } }
      it 'should return designated Races' do
        is_expected.to eq [1, 2, 3, 4]
      end
    end

    context 'by course' do
      let(:search_params) { { course: COURSE_ID_KYOTO } }
      it 'should return designated Races' do
        is_expected.to eq [3]
      end
    end

    context 'by number' do
      let(:search_params) { { number: 11 } }
      it 'should return designated Races' do
        is_expected.to eq [1]
      end
    end

    context 'by race_class' do
      let(:search_params) { { race_class: [RACE_CLASS_ID_G1, RACE_CLASS_ID_G2] } }
      it 'should return designated Races' do
        is_expected.to eq [1, 2, 4]
      end
    end

    context 'by duration' do
      before do
        @start = Date.parse('2023-03-21')
        @end = Date.parse('2023-03-29')
      end
      let(:search_params) { { duration: @start..@end } }
      it 'should return designated Races' do
        is_expected.to eq [3, 4]
      end
    end
  end
end
