# frozen_string_literal: true

# require 'rails_helper'
require 'uma2/optimizer'

RSpec.describe 'Uma2::Optimizer' do
  describe 'when end_time is given' do
    before do
      @optimizer = Uma2::Optimizer.new
    end

    it '#new creates params' do
      expect(@optimizer.params[:a].class).to eq Uma2::Optimizer::Weight
      expect(@optimizer.params[:b].class).to eq Uma2::Optimizer::Certainty
      expect(@optimizer.params[:t].class).to eq Uma2::Optimizer::TrueDistribution
    end
  end
end
