# frozen_string_literal: true

require 'rails_helper'
require 'uma2/proposer'

RSpec.describe 'Uma2::Proposer' do
  describe '#new' do
    subject { @proposer = Uma2::Proposer.new(params, odds, bet) }
    let(:params) { params_data }
    let(:odds) { odds_data }

    context 'with integer bet' do
      let(:bet) { 10 }
      it 'gives a proposer' do
        is_expected.to be_a Uma2::Proposer
        expect(@proposer.t).to be_a Uma2::Probability
      end
    end

    context 'with non-integer bet' do
      let(:bet) { 9.8 }
      it 'raises RuntimeError' do
        exception_expected = 'Only integer bet is permitted'
        expect { subject }.to raise_error(exception_expected)
      end
    end
  end

  describe '#base_strategy' do
    before { @proposer = Uma2::Proposer.new(params, odds, bet) }
    subject { @strategy = @proposer.base_strategy }
    let(:params) { params_data }
    let(:odds) { odds_data }
    let(:bet) { 10 }

    it 'gives a strategy as Probability' do
      is_expected.to be_a Uma2::Probability
      expect(@strategy[2]).to be > @strategy[0]
      expect(@strategy[2]).to be > @strategy[1]
    end
  end

  describe '#gain_strategy' do
    before { @proposer = Uma2::Proposer.new(params, odds, bet) }
    subject { @strategy = @proposer.gain_strategy }
    let(:params) { params_data }
    let(:odds) { odds_data }
    let(:bet) { 10 }

    it 'gives a strategy as Proposer::Strategy' do
      is_expected.to be_a Uma2::Proposer::Strategy
      expect(@strategy.sum).to eq bet
    end
  end

  describe '#hit_strategy' do
    before { @proposer = Uma2::Proposer.new(params, odds, bet) }
    subject { @strategy = @proposer.hit_strategy }
    let(:params) { params_data }
    let(:odds) { odds_data }
    let(:bet) { 10 }

    it 'gives a strategy as Proposer::Strategy' do
      is_expected.to be_a Uma2::Proposer::Strategy
      expect(@strategy.sum).to eq bet
    end
  end

  def params_data
    {
      'b' => [1.0, 1.5, 1.25],
      't' => [0.1, 0.3, 0.6],
    }
  end

  def odds_data
    [4.0, 2.67, 1.6]
  end
end
