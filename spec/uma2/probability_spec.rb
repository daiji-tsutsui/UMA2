# frozen_string_literal: true

require 'rails_helper'
require 'uma2/probability'

RSpec.describe 'Uma2::Probability' do
  describe '#new' do
    it 'with no args' do
      vect = Uma2::Probability.new
      expect(vect).to eq [1.0]
    end

    context 'with an arg' do
      before do
        @arg = [0.1, 0.3, 0.4]
        @vect = Uma2::Probability.new(@arg)
      end

      it 'gives the summation 1' do
        expect(@vect.sum).to eq 1.0
      end
      it 'gives the same ratio as an arg' do
        arg_ratio = @arg.map { |a| a / @arg[0] }
        vect_ratio = @vect.map { |v| v / @vect[0] }
        expect(vect_ratio).to eq arg_ratio
      end
    end

    it 'with nil' do
      vect = Uma2::Probability.new(nil)
      expect(vect).to eq [1.0]
    end
  end

  describe '#kl_div' do
    before do
      @ini = [1.0, 3.0, 4.0]
      @src = Uma2::Probability.new(@ini)
    end

    it 'gives zero when compared with itself' do
      expect(@src.kl_div(@src)).to eq 0.0
    end
    describe 'gives a positive value when compared with other one' do
      it '#1' do
        other1 = Uma2::Probability.new([1.0, 1.0, 1.0])
        expect(@src.kl_div(other1) > 0).to be_truthy
      end
      it '#2' do
        other2 = Uma2::Probability.new([1.0, 2.0, 3.0])
        expect(@src.kl_div(other2) > 0).to be_truthy
      end
      it '#3' do
        other3 = Uma2::Probability.new([1.0, 3.0, 4.1])
        expect(@src.kl_div(other3) > 0).to be_truthy
      end
    end
  end

  describe '#move!' do
    before do
      @ini = [0.125, 0.375, 0.5]
      @src = Uma2::Probability.new(@ini)
    end

    it 'moves self in the meaning of m-parallel transportation' do
      v = [0.01, 0.01]
      @src.move!(v)
      expect(@src[0]).to be_within(1e-6).of(0.125 - 0.02)
      expect(@src[1]).to be_within(1e-6).of(0.375 + 0.01)
      expect(@src[2]).to be_within(1e-6).of(0.5 + 0.01)
    end
    it 'does not move self when v is zero' do
      v = [0.0, 0.0]
      @src.move!(v)
      expect(@src).to eq @ini
    end
  end

  describe '#move_with_natural_grad!' do
    before do
      @ini = [0.125, 0.375, 0.5]
      @src = Uma2::Probability.new(@ini)
    end

    describe 'moves self in the direction of natural gradient' do
      before do
        v = [0.1, 0.1]
        @src.move_with_natural_grad!(v)
      end

      it 'gives result close to the initial value' do
        expect(@src[0]).to within(0.1).of(0.125)
        expect(@src[1]).to within(0.1).of(0.375)
        expect(@src[2]).to within(0.1).of(0.5)
      end
      it 'gives result with its summation 1' do
        expect(@src.sum).to eq 1.0
      end
    end

    it 'does not move self when v is 0' do
      v = [0.0, 0.0]
      @src.move_with_natural_grad!(v)
      expect(@src).to eq @ini
    end
  end

  describe '#extend_to!' do
    before do
      @ini = [1.0, 2.0, 3.0]
      @src = Uma2::Probability.new(@ini)
    end

    context 'extends self' do
      before do
        @src.extend_to!(5)
      end
      it 'with keeping the summation 1' do
        expect(@src.sum).to eq 1.0
      end
      it 'by adding the same values' do
        expect(@src[-1] == @src[-2]).to be_truthy
      end
      it 'by dividing the original elements' do
        expect(@src[0..2].sum).to eq 0.6
      end
    end
    it 'raises exception when trg_size is less than self size' do
      expect { @src.extend_to!(2) }.to raise_error(ArgumentError)
    end
  end

  describe 'class methods' do
    describe '#new_from_odds' do
      before do
        @arg = [0.1, 0.3, 0.4]
        @vect = Uma2::Probability.new_from_odds(@arg)
      end

      it 'gives the summation 1' do
        expect(@vect.sum).to eq 1.0
      end
      it 'gives the inverse ratio of arg' do
        prod = @vect.schur(@arg)
        expect(prod[0]).to within(1e-6).of(prod[1])
        expect(prod[0]).to within(1e-6).of(prod[-1])
      end
    end

    describe '#delta' do
      it 'returns 1.0 when i == j' do
        expect(Uma2::Probability.delta(1, 1)).to eq 1.0
        expect(Uma2::Probability.delta(2, 2)).to eq 1.0
        expect(Uma2::Probability.delta(5, 5)).to eq 1.0
      end
      it 'returns 0.0 when i != j' do
        expect(Uma2::Probability.delta(1, 2)).to eq 0.0
        expect(Uma2::Probability.delta(2, 4)).to eq 0.0
        expect(Uma2::Probability.delta(3, 1)).to eq 0.0
        expect(Uma2::Probability.delta(5, 2)).to eq 0.0
      end
    end
  end
end
