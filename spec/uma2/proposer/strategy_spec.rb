# frozen_string_literal: true

require 'rails_helper'
require 'uma2/proposer/strategy'

RSpec.describe 'Uma2::Proposer::Strategy' do
  describe '#new' do
    subject { Uma2::Proposer::Strategy.new(src, param_t, odds) }
    let(:odds) { [4.0, 2.67, 1.6] }

    context 'with non-integer src' do
      let(:src) { [1.5, 2.0, 3.75] }
      let(:param_t) { Uma2::Probability.new([0.1, 0.3, 0.6]) }
      it 'makes strategy with integer entries' do
        is_expected.to eq [1, 2, 3]
      end
    end

    context 'with negative src' do
      let(:src) { [-1, 2, -3] }
      let(:param_t) { Uma2::Probability.new([0.1, 0.3, 0.6]) }
      it 'makes strategy with nonnegative entries' do
        is_expected.to eq [0, 2, 0]
      end
    end

    context 'with non-probability param_t' do
      let(:src) { [1, 2, 3] }
      let(:param_t) { [0.1, 0.3, 0.6] }
      it 'raises RuntimeError' do
        exception_expected = 'param_t must be Uma2::Probability'
        expect { subject }.to raise_error(exception_expected)
      end
    end
  end

  describe '#expectation' do
    before { @strategy = Uma2::Proposer::Strategy.new(src, param_t, odds) }
    subject { @strategy.expectation }
    let(:odds) { [4.0, 2.67, 1.6] }
    let(:src) { [1, 2, 3] }
    let(:param_t) { Uma2::Probability.new([0.1, 0.3, 0.6]) }

    it 'gives a expected gain' do
      expected_gain = odds.map.with_index { |o_i, i| o_i * src[i] * param_t[i] }.sum
      is_expected.to eq expected_gain
    end
  end

  describe '#probability' do
    before { @strategy = Uma2::Proposer::Strategy.new(src, param_t, odds) }
    subject { @strategy.probability }
    let(:odds) { [4.0, 2.67, 1.6] }
    let(:param_t) { Uma2::Probability.new([0.1, 0.3, 0.6]) }

    context 'with a zero entry' do
      let(:src) { [0, 2, 3] }
      it 'gives a value between 0 and 1' do
        is_expected.to be_between(0.0, 1.0).exclusive
      end
    end

    context 'without zero entries' do
      let(:src) { [1, 2, 3] }
      it 'gives strictry 1' do
        is_expected.to eq 1.0
      end
    end
  end

  describe '#redistribute!' do
    before { @strategy = Uma2::Proposer::Strategy.new(src, param_t, odds) }
    subject { @strategy.redistribute!(bet, order) }
    let(:odds) { [4.0, 2.67, 1.6] }
    let(:src) { [1, 2, 3] }
    let(:param_t) { Uma2::Probability.new([0.1, 0.3, 0.6]) }

    context 'with bet more than betting now' do
      let(:bet) { 8 }
      let(:order) { [2, 1, 0] }
      it 'makes strategy betting more' do
        subject
        expect(@strategy).to eq [1, 3, 4]
      end
    end

    context 'with bet equal to betting now' do
      let(:bet) { 6 }
      let(:order) { [2, 1, 0] }
      it 'makes no changes' do
        expect { subject }.not_to(change { @stragety })
      end
    end

    context 'with bet less than betting now' do
      let(:bet) { 5 }
      let(:order) { [2, 1, 0] }
      it 'makes no changes' do
        expect { subject }.not_to(change { @stragety })
      end
    end
  end

  describe '#+' do
    before { @strategy = Uma2::Proposer::Strategy.new(src, param_t, odds) }
    subject { @strategy + sub_strategy }
    let(:odds) { [4.0, 2.67, 1.6] }
    let(:src) { [1, 2, 3] }
    let(:param_t) { Uma2::Probability.new([0.1, 0.3, 0.6]) }
    let(:sub_strategy) { [1, 1, 1] }

    it 'adds sub_strategy to self' do
      is_expected.to eq [2, 3, 4]
      expect(@strategy).to eq [2, 3, 4]
    end
  end
end
