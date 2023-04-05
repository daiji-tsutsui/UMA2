# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe 'Stats', type: :request do
  describe 'GET /stats' do
    subject { get stats_path }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'should have chart element' do
      subject
      expect(response.body).to include('<div id="chart"></div>')
      expect(response.body).to include('<span id="gain_average">')
      expect(response.body).to include('<span id="hit_average">')
    end

    it 'renders form for statistics' do
      is_expected.to render_template('_form')
    end
  end

  describe 'GET /stats/api' do
    subject { get '/stats/api' }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'should have desired structure' do
      subject
      res = JSON.parse(response.body)
      expect(res).to include('averages')
      expect(res).to include('time_seq')
      expect(res['averages']).to include('gain_average')
      expect(res['averages']).to include('hit_average')
      expect(res['time_seq']).to be_a Array
      expect(res['time_seq'].first).to include('gain_actual')
      expect(res['time_seq'].first).to include('hit_expected')
    end
  end
end
