# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stats', type: :request do
  describe 'GET /stats' do
    subject { get stats_path }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'should have chart element' do
      subject
      expect(response.body).to include('<div id="gain_chart"></div>')
    end

    it 'renders form for statistics' do
      is_expected.to render_template('_form')
    end
  end
end
