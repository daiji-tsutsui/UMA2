# frozen_string_literal: true

# require 'rails_helper'
require 'uma2/optimizer/certainty'

RSpec.describe 'Certainty' do
  describe 'when end_time is given' do
    before do
      @b = Uma2::Optimizer::Certainty.new
    end

    it '#update raises error' do
      expect { @b.update }.to raise_error('Define Me')
    end
  end
end
