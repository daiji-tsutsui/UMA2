# frozen_string_literal: true

require 'rails_helper'
require 'uma2/optimizer/true_distribution'

RSpec.describe 'TrueDistribution' do
  before do
    @t = Uma2::Optimizer::TrueDistribution.new
  end

  it 'is a probability' do
    expect(@t).to be_a(Uma2::Probability)
  end

  describe 'when model is given' do
    before do
      @model = Uma2::Optimizer::Model.new
      @model.forecast(odds_list_data, params_data)
      @t = params_data[:t]
      @a = params_data[:a]
      @b = params_data[:b]
    end

    it '#update changes own values' do
      old_t = @t.clone
      @t.update(odds_list_data, @model, @a, @b)
      expect(abs_distance(@t, old_t)).to be > 1e-3
    end
  end

  describe 'when model is constant' do
    before do
      @model = Uma2::Optimizer::Model.new
      @model.forecast(odds_list_data_constant, params_data_constant)
      @t = params_data_constant[:t].clone
      @a = params_data_constant[:a].clone
      @b = params_data_constant[:b].clone
    end

    it '#update does NOT change own values' do
      old_t = @t.clone
      @t.update(odds_list_data_constant, @model, @a, @b)
      expect(abs_distance(@t, old_t)).to be < 1e-6
    end
  end

  def abs_distance(new, old)
    new.map.with_index { |val_k, k| (val_k - old[k]).abs }.sum
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
      [2.67, 2.67, 2.67],
      [2.67, 2.67, 2.67],
      [2.67, 2.67, 2.67],
      [2.67, 2.67, 2.67],
    ]
  end

  def params_data_constant
    {
      a: Uma2::Optimizer::Weight.new([0.25, 0.25, 0.25, 0.25]),
      b: Uma2::Optimizer::Certainty.new([1.0, 1.0, 1.0, 1.0]),
      t: Uma2::Optimizer::TrueDistribution.new([0.33, 0.33, 0.33]),
    }
  end
end
