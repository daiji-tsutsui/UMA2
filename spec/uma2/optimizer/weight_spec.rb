# frozen_string_literal: true

require 'rails_helper'
require 'uma2/optimizer/weight'

RSpec.describe 'Weight' do
  describe 'when end_time is given' do
    before do
      @a = Uma2::Optimizer::Weight.new
    end

    xit '#update raises error' do
      expect { @a.update }.to raise_error('Define Me')
    end
  end
end
