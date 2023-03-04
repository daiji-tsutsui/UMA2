# frozen_string_literal: true

require 'rails_helper'
require 'uma2/optimizer/true_distribution'

RSpec.describe 'TrueDistribution' do
  describe 'when end_time is given' do
    before do
      @t = Uma2::Optimizer::TrueDistribution.new
    end

    xit '#update raises error' do
      expect { @t.update }.to raise_error('Define Me')
    end
  end
end
