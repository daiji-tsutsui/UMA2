# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Races', type: :request do
  describe 'GET /races' do
    before { get races_path }

    it 'should response success' do
      expect(response).to have_http_status(200)
    end

    it 'renders table of races' do
      # table headers
      expect(response.body).to include('レース名')
      expect(response.body).to include('出走日')
      expect(response.body).to include('競馬場')
      # table rows
      expect(response.body).to include('2022-10-22')
      expect(response.body).to include('札幌')
      expect(response.body).to include('Test2')
      # class identifier
      expect(response.body).to include('raceclass-G2')
    end
  end

  describe 'GET /races/:id' do
    before { get race_path(1) }

    it 'should response success' do
      expect(response).to have_http_status(200)
    end

    it 'renders table of a race' do
      # h1 tag
      expect(response.body).to include('Test1')
      # race table headers
      expect(response.body).to include('出走時刻')
      expect(response.body).to include('レース番号')
      expect(response.body).to include('距離')
      # race table rows
      expect(response.body).to include('2022-10-22')
      expect(response.body).to include('札幌')
      expect(response.body).to include('11R')
      # horse table headers
      expect(response.body).to include('馬番')
      expect(response.body).to include('性齢')
      expect(response.body).to include('騎手')
      # horse table rows
      expect(response.body).to include('タニノギムレット')
      expect(response.body).to include('牡4')
      expect(response.body).to include('横山武')
      # class identifier
      expect(response.body).to include('raceclass-G1')
    end
  end
end
