# frozen_string_literal: true

require 'rails_helper'
require 'uma2/proposer'

RSpec.describe 'Uma2::Proposer' do
  describe '#new' do
    subject { @proposer = Uma2::Proposer.new(params, odds) }
    let(:params) { params_data }
    let(:odds) { odds_data }

    it 'gives a proposer' do
      is_expected.to be_a Uma2::Proposer
      expect(@proposer.t).to be_a Uma2::Probability
    end
  end

  describe '#base_strategy' do
    before { @proposer = Uma2::Proposer.new(params, odds, option: option) }
    subject { @strategy = @proposer.base_strategy }
    let(:params) { params_data }
    let(:odds) { odds_data }
    let(:option) { nil }

    it 'gives a strategy as Distribution' do
      is_expected.to be_a Uma2::Proposer::Distribution
      expect(@strategy[2]).to be > @strategy[0]
      expect(@strategy[2]).to be > @strategy[1]
      expect(@strategy[2]).to be < 0.5
    end

    context 'with small certainty' do
      let(:option) { { certainty: 0.5 } }
      it 'gives small mass' do
        subject
        expect(@strategy[2]).to be < 0.4
      end
    end

    context 'with large certainty' do
      let(:option) { { certainty: 10.0 } }
      it 'gives large mass' do
        subject
        expect(@strategy[2]).to be > 0.8
      end
    end
  end

  describe '#gain_strategy' do
    before { @proposer = Uma2::Proposer.new(params, odds, option: option) }
    subject { @strategy = @proposer.gain_strategy }
    let(:params) { params_data }
    let(:odds) { odds_data }
    let(:option) { nil }

    it 'gives a strategy as Proposer::Strategy' do
      is_expected.to be_a Uma2::Proposer::Strategy
      default_bet = Settings.uma2.proposer.default_bet
      expect(@strategy.sum).to eq default_bet
    end
  end

  describe '#hit_strategy' do
    before { @proposer = Uma2::Proposer.new(params, odds, option: option) }
    subject { @strategy = @proposer.hit_strategy }
    let(:params) { params_data }
    let(:odds) { odds_data }
    let(:option) { { bet: 5 } }

    it 'gives a strategy as Proposer::Strategy' do
      is_expected.to be_a Uma2::Proposer::Strategy
      expect(@strategy.sum).to eq option[:bet]
    end

    context 'without minimum_hit' do
      let(:option) { { bet: 5 } }
      it 'guarantees default hit probability' do
        subject
        default_min_hit = Settings.uma2.proposer.hit_probability_min
        expect(@strategy.probability).to be > default_min_hit
        expect(@strategy.probability).to be < 0.9
      end
    end

    context 'with large minimum_hit' do
      let(:option) { { bet: 5, minimum_hit: 0.99 } }
      it 'gives large hit probability' do
        subject
        expect(@strategy.probability).to be > 0.99
      end
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
