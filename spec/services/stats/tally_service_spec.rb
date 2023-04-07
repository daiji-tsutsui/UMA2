# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stats::TallyService' do
  describe '#call' do
    subject { @res = Stats::TallyService.new(races, dates, params).call }
    let(:races) { Race.all }
    let(:dates) { RaceDate.all }
    let(:params) { params_data }

    it 'gives hash which has race_date_id as its keys' do
      is_expected.to be_a Hash
      expect(@res.keys).to eq dates.map(&:id)
    end

    it 'gives formatted data for each race_date' do
      subject
      data = @res.values.first
      expected_keys = %i[gain_actual gain_expected gain_total hit_actual hit_expected hit_total target_size]
      expect(data.keys).to match_array expected_keys
    end

    it 'gives zeros for race_date without odds_history and optimization' do
      subject
      data = @res[1]
      expect(data[:gain_actual]).to eq 0.0
      expect(data[:target_size]).to eq 0.0
    end

    it 'gives nonzero values for race_date with odds_history and optimization' do
      subject
      data = @res[3]
      expect(data[:gain_actual]).to_not eq 0.0
      expect(data[:target_size]).to_not eq 0
    end
  end

  private

  def params_data
    {
      bet:         10,
      certainty:   1.0,
      minimum_hit: 0.9,
    }
  end
end
