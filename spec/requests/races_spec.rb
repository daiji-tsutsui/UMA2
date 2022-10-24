# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Races', type: :request do
  describe 'GET /races' do
    it 'should response success' do
      get races_path
      assert_response :success
    end
  end

  describe 'GET /races/:id' do
    it 'should response success' do
      get race_path(1)
      assert_response :success
    end
  end
end
