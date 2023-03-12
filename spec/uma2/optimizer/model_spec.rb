# frozen_string_literal: true

require 'rails_helper'
require 'uma2/optimizer/model'

RSpec.describe 'Uma2::Optimizer::Model' do
  xdescribe '#strategy' do
    subject { Uma2::Optimizer::Model.strategy(odds, b, t) }

    context 'with uniform odds and t' do
      let(:odds) { [2.4, 2.4, 2.4] }
      let(:b)    { 1.0 }
      let(:t)    { Uma2::Probability.new([0.33, 0.33, 0.33]) }
      it 'gives a probability distribution' do
        is_expected.to be_a Uma2::Probability
      end
      it 'gives a uniform distribution' do
        s = subject
        expect(s[0]).to eq s[1]
        expect(s[0]).to eq s[2]
      end
    end

    context 'with nonuniform odds and t' do
      let(:odds) { [3.2, 3.2, 1.6] }
      let(:t)    { Uma2::Probability.new([0.4, 0.2, 0.4]) }

      context 'if b is large' do
        let(:b) { 10.0 }
        it 'gives a sharp distribution' do
          s = subject
          expect(s[0]).to be > s[1]
          expect(s[0]).to be > s[2]
          expect(s[0]).to within(0.01).of(1.0)
        end
      end

      context 'if b is small' do
        let(:b) { 0.01 }
        it 'gives a flat distribution' do
          s = subject
          expect(s[0]).to be > s[1]
          expect(s[0]).to be > s[2]
          expect(s[0]).to within(0.01).of(0.33)
        end
      end
    end
  end

  describe '#new' do
    subject { @model = Uma2::Optimizer::Model.new }

    it 'initializes model parameters' do
      is_expected.to be_a Uma2::Optimizer::Model
      expect(@model.series).to be_empty
      expect(@model.strategies).to be_empty
    end
  end

  describe '#forecast' do
    before { @model = Uma2::Optimizer::Model.new }
    subject { @model.forecast(odds_list, params) }

    context 'with no odds_list' do
      let(:odds_list) { [] }
      let(:params) { params_data }
      it 'raises NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'with no params' do
      let(:odds_list) { odds_list_data }
      let(:params) { {} }
      it 'raises NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'with non-adjusted odds_list and params' do
      let(:odds_list) { odds_list_data_too_long }
      let(:params) { params_data }
      it 'raises NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'with proper odds_list and params' do
      let(:odds_list) { odds_list_data }
      let(:params) { params_data }

      it 'creates time series of distributions with proper size' do
        subject
        expect(@model.series.size).to eq params[:a].size - 1
        expect(@model.series[0]).to be_a Uma2::Probability
        expect(@model.series[0].size).to eq params[:t].size
      end

      it 'creates strategies with proper size' do
        subject
        expect(@model.strategies.size).to eq params[:b].size - 1
        expect(@model.strategies[0]).to be_a Uma2::Probability
        expect(@model.strategies[0].size).to eq odds_list[0].size
      end
    end
  end

  describe '#loss' do
    before { @model = Uma2::Optimizer::Model.new }
    subject { @model.loss(odds_list) }

    context 'without forecasting' do
      let(:odds_list) { odds_list_data }
      it 'returns 0.0' do
        is_expected.to eq 0.0
      end
    end

    context 'with forecasting' do
      before { @model.forecast(odds_list, params_data) }
      let(:odds_list) { odds_list_data }
      it 'outputs a positive value' do
        is_expected.to be > 0.1
      end
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

  def odds_list_data_too_long
    [
      [3.2,  3.2,  1.6],
      [4.0,  2.67, 1.6],
      [5.33, 2.67, 1.45],
      [5.33, 2.29, 1.6],
      [4.0,  2.67, 1.6],
    ]
  end

  def params_data
    {
      a: Uma2::Optimizer::Weight.new([0.25, 0.25, 0.25, 0.25]),
      b: Uma2::Optimizer::Certainty.new([1.0, 2.0, 3.0, 2.5]),
      t: Uma2::Optimizer::TrueDistribution.new([0.25, 0.35, 0.4]),
    }
  end
end
