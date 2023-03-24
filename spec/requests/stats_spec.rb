# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stats', type: :request do
  describe 'GET /stats' do
    subject { get stats_path }

    it 'should response success' do
      is_expected.to eq 200
    end
  end
end
