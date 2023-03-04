# frozen_string_literal: true

require 'rails_helper'
require 'uma2/optimizer/weight'

RSpec.describe 'Weight' do
  before do
    @a = Uma2::Optimizer::Weight.new
  end

  it 'is a probability' do
    expect(@a).to be_a(Uma2::Probability)
  end

  describe 'when model is given' do
    before do
      @model = Uma2::Optimizer::Model.new
      @model.forecast(odds_list_data, params_data)
      @a = params_data[:a].clone
    end

    it '#update changes own values' do
      old_a = @a.clone
      @a.update(odds_list_data, @model)
      distance = @a.map.with_index { |a_k, k| (a_k - old_a[k]).abs }.sum
      expect(distance).to be > 1e-3
    end
  end

  describe 'when model is constant' do
    before do
      @model = Uma2::Optimizer::Model.new
      @model.forecast(odds_list_data_constant, params_data_constant)
      @a = params_data_constant[:a].clone
    end

    it '#update changes own values a bit' do
      old_a = @a.clone
      @a.update(odds_list_data_constant, @model)
      distance = @a.map.with_index { |a_k, k| (a_k - old_a[k]).abs }.sum
      expect(distance).to be < 1e-3
    end
  end

  def odds_list_data
    [
      [3.2,  3.2,  1.6],
      [4.0,  2.67, 1.6],
      [5.33, 2.67, 1.45],
      [5.33, 2.29, 1.6],
    ]
  end

  def params_data
    {
      a: Uma2::Optimizer::Weight.new([0.25, 0.25, 0.25, 0.25]),
      b: Uma2::Optimizer::Certainty.new([1.0, 2.0, 3.0, 2.5]),
      t: Uma2::Optimizer::TrueDistribution.new([0.25, 0.35, 0.4]),
    }
  end

  def odds_list_data_constant
    [
      [4.0,  2.667, 1.6],
      [4.0,  2.667, 1.6],
      [4.0,  2.667, 1.6],
      [4.0,  2.667, 1.6],
    ]
  end

  def params_data_constant
    {
      a: Uma2::Optimizer::Weight.new([0.55, 0.15, 0.15, 0.15]),
      b: Uma2::Optimizer::Certainty.new([1.0, 1.0, 1.0, 1.0]),
      t: Uma2::Optimizer::TrueDistribution.new([0.2, 0.3, 0.5]),
    }
  end
end
