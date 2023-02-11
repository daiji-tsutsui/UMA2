# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Races', type: :request do
  describe 'GET /races' do
    subject { get races_path }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'renders table of races' do
      subject
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
    subject { get race_path(1) }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'renders information table of a race' do
      is_expected.to render_template('_info_table')
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
      # class identifier
      expect(response.body).to include('raceclass-G1')
    end

    it 'renders horses table of a race' do
      is_expected.to render_template('_horse_table')
      # horse table headers
      expect(response.body).to include('馬番')
      expect(response.body).to include('性齢')
      expect(response.body).to include('騎手')
      # horse table rows
      expect(response.body).to include('タニノギムレット')
      expect(response.body).to include('牡4')
      expect(response.body).to include('横山武')
    end

    it 'renders odds table of a race' do
      is_expected.to render_template('_odds_history')
      # odds table headers
      expect(response.body).to include('&#35;')
      expect(response.body).to include('取得時刻')
      # odds table rows
      expect(response.body).to include('14:15:30')
      expect(response.body).to include('16.0')
    end
  end
end
