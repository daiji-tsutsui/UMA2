# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Horses', type: :request do
  describe 'GET /horses' do
    subject { get horses_path }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'renders table of horses' do
      subject
      # table headers
      expect(response.body).to include('馬名')
      expect(response.body).to include('直近のレース')
      expect(response.body).to include('成績')
      # table rows
      expect(response.body).to include('ハリボテエレジー')
      expect(response.body).to include('アシタハレルカナ')
      expect(response.body).to include('タニノギムレット')
      expect(response.body).to include('ダイダバッター')
    end
  end

  describe 'GET /horses/:id' do
    subject { get horse_path(1) }

    it 'should response success' do
      is_expected.to eq 200
    end

    it 'renders table of a horse' do
      subject
      # h1 tag
      expect(response.body).to include('ハリボテエレジー')
      # race table headers
      expect(response.body).to include('出走レース')
      expect(response.body).to include('馬番')
      expect(response.body).to include('性齢')
      # race table rows
      expect(response.body).to include('Test1')
      expect(response.body).to include('Test2')
      expect(response.body).to include('デムーロ')
      # class identifier
      expect(response.body).to include('raceclass-G1')
      expect(response.body).to include('raceclass-G2')
    end
  end
end
