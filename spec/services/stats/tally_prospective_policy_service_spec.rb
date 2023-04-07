# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stats::TallyProspectivePolicyService' do
  describe '#call' do
    subject { @res = Stats::TallyProspectivePolicyService.new(races, dates, params).call }
    let(:races) { Race.all }
    let(:dates) { RaceDate.all }
    let(:params) { {} }

    it 'gives formatted data for each race_date' do
      subject
      data = @res.values.first
      expected_keys = %i[
        pp_gain_actual pp_gain_expected pp_gain_total pp_hit_actual pp_hit_expected pp_hit_total target_size
      ]
      expect(data.keys).to match_array expected_keys
    end
  end
end
