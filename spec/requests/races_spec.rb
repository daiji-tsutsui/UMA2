# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Races', type: :request do
  describe 'GET /races' do
    before { get races_path }

    it 'should response success' do
      expect(response).to have_http_status(200)
    end

    it 'renders table of races' do
      expect(response.body).to include('レース名')
      expect(response.body).to include('出走日')
      expect(response.body).to include('2022-10-22')
      expect(response.body).to include('札幌')
      expect(response.body).to include('Test2')
      expect(response.body).to include('G2')
    end
  end

  describe 'GET /races/:id' do
    before { get race_path(1) }

    it 'should response success' do
      expect(response).to have_http_status(200)
    end

    it 'renders table of a race' do
      expect(response.body).to include('格付')
      expect(response.body).to include('天気')
      expect(response.body).to include('Test1')
      expect(response.body).to include('2022-10-22')
      expect(response.body).to include('札幌')
      expect(response.body).to include('11R')
      expect(response.body).to include('G1')
    end
  end
end
