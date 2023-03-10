# frozen_string_literal: true

require 'rails_helper'
require 'uma2/optimizer'

RSpec.describe 'Uma2::Optimizer' do
  describe '#new' do
    subject { @optimizer = Uma2::Optimizer.new(params: params) }

    context 'with no params' do
      let(:params) { {} }
      it 'creates new parameters' do
        subject
        expect(@optimizer.a).to be_a Uma2::Optimizer::Weight
        expect(@optimizer.b).to be_a Uma2::Optimizer::Certainty
        expect(@optimizer.t).to be_a Uma2::Optimizer::TrueDistribution
        expect(@optimizer.a).to eq [1.0]
        expect(@optimizer.b).to eq [1.0]
        expect(@optimizer.t).to eq [1.0]
      end
    end

    context 'with params' do
      let(:params) { params_data1 }
      it 'takes over given parameters' do
        subject
        expect(@optimizer.a).to be_a Uma2::Optimizer::Weight
        expect(@optimizer.b).to be_a Uma2::Optimizer::Certainty
        expect(@optimizer.t).to be_a Uma2::Optimizer::TrueDistribution
        expect(@optimizer.a).to eq [0.2, 0.8]
        expect(@optimizer.b).to eq [1.0, 2.0]
        expect(@optimizer.t).to eq [0.2, 0.3, 0.5]
      end
    end
  end

  describe '#add_odds' do
    before { @optimizer = Uma2::Optimizer.new(params: params_data1) }
    subject { @optimizer.add_odds(odds_histories) }

    context 'with larger odds histories than optimizer size' do
      let(:odds_histories) { odds_histories_data1 }
      it 'extends optimizer size to odds histories size' do
        expect { subject }.to change { @optimizer.a.size }.by(2)
        expect(@optimizer.b.size).to eq odds_histories.size
        expect(@optimizer.t.size).to eq odds_histories[0].size
      end
    end

    context 'with smaller odds histories than optimizer size' do
      let(:odds_histories) { [[3.2, 3.2, 1.6]] }
      it 'does NOT change optimizer size' do
        expect { subject }.to_not(change { @optimizer.a.size })
        expect(@optimizer.b.size).to be > odds_histories.size
      end
    end

    context 'if optimizer has no params' do
      before { @optimizer = Uma2::Optimizer.new }
      let(:odds_histories) { odds_histories_data1 }

      it 'extends time parameters size' do
        expect { subject }.to change { @optimizer.b.size }.by(3)
        expect(@optimizer.a.size).to eq odds_histories.size
      end

      it 'extends true distribution size' do
        expect { subject }.to change { @optimizer.t.size }.by(2)
        expect(@optimizer.t.size).to eq odds_histories[0].size
      end
    end
  end

  describe '#run' do
    before do
      @optimizer = Uma2::Optimizer.new(params: params_data1)
      @optimizer.add_odds(odds_histories_data1)
    end
    subject { @optimizer.run(iteration) }

    context 'for 10 iteration' do
      before { allow(@optimizer).to receive(:update!).and_return(1) }
      let(:iteration) { 10 }
      it 'calls #update! 10 times' do
        subject
        expect(@optimizer).to have_received(:update!).exactly(iteration).times
      end
    end

    context 'for 20 iteration' do
      before { allow(@optimizer).to receive(:update!).and_return(1) }
      let(:iteration) { 20 }
      it 'calls #update! 20 times' do
        subject
        expect(@optimizer).to have_received(:update!).exactly(iteration).times
      end
    end
  end

  describe '#loss' do
    before do
      @optimizer = Uma2::Optimizer.new(params: params)
      @optimizer.add_odds(odds_histories)
      @optimizer.run(1)
    end
    subject { @optimizer.loss }

    context 'with pattern #1' do
      let(:params) { params_data1 }
      let(:odds_histories) { odds_histories_data1 }

      it 'gives a positive value' do
        is_expected.to be > 0.1
      end

      it 'gives the same values before updation' do
        old_loss = @optimizer.loss
        is_expected.to be_within(1e-6).of(old_loss)
      end

      it 'decreases loss function' do
        old_loss = @optimizer.loss
        @optimizer.run(1)
        is_expected.to be < old_loss - 1e-4
      end
    end

    context 'with pattern #2' do
      let(:params) { params_data2 }
      let(:odds_histories) { odds_histories_data2 }

      it 'gives a positive value' do
        is_expected.to be > 0.02
      end

      it 'gives the same values before updation' do
        old_loss = @optimizer.loss
        is_expected.to be_within(1e-6).of(old_loss)
      end

      it 'decreases loss function' do
        old_loss = @optimizer.loss
        @optimizer.run(1)
        is_expected.to be < old_loss - 1e-4
      end
    end

    context 'with pattern #3' do
      let(:params) { params_data3 }
      let(:odds_histories) { odds_histories_data3 }

      it 'gives a positive value' do
        is_expected.to be > 0.1
      end

      it 'gives the same values before updation' do
        old_loss = @optimizer.loss
        is_expected.to be_within(1e-6).of(old_loss)
      end

      it 'decreases loss function' do
        old_loss = @optimizer.loss
        @optimizer.run(1)
        is_expected.to be < old_loss - 1e-4
      end
    end

    context 'with equilibrium parameters' do
      let(:params) { params_data_equilibrium }
      let(:odds_histories) { odds_histories_data_equilibrium }

      it 'gives a very small positive value' do
        is_expected.to be > 1e-6
        is_expected.to be < 1e-5
      end

      it 'does NOT decrease loss function' do
        old_loss = @optimizer.loss
        @optimizer.run(1)
        is_expected.to be < old_loss
        is_expected.to be > old_loss - 1e-6
      end
    end
  end

  describe '#converges?' do
    before do
      @optimizer = Uma2::Optimizer.new(params: params)
      @optimizer.add_odds(odds_histories)
      allow(Settings.uma2).to receive(:check_loss_interval).and_return(1)
    end
    subject { @optimizer.converges? }

    context 'with non-equilibrium parameters' do
      let(:params) { params_data1 }
      let(:odds_histories) { odds_histories_data1 }

      it 'returns false' do
        @optimizer.run(2)
        is_expected.to be_falsy
      end
    end

    context 'with equilibrium parameters' do
      let(:params) { params_data_equilibrium }
      let(:odds_histories) { odds_histories_data_equilibrium }

      it 'returns true' do
        @optimizer.run(2)
        is_expected.to be_truthy
      end
    end

    context 'with the only 1 #run' do
      let(:params) { params_data_equilibrium }
      let(:odds_histories) { odds_histories_data_equilibrium }

      it 'necessarily returns false' do
        @optimizer.run(1)
        is_expected.to be_falsy
      end
    end
  end

  # 2 time-units smaller than odds_histories_data1
  def params_data1
    {
      'a' => [0.2, 0.8],
      'b' => [1.0, 2.0],
      't' => [0.2, 0.3, 0.5],
    }
  end

  def odds_histories_data1
    [
      [3.2,  3.2,  1.6],
      [4.0,  2.67, 1.6],
      [5.33, 2.67, 1.45],
      [5.33, 2.29, 1.6],
    ]
  end

  # According to odds_histories_data2 to some extent
  def params_data2
    {
      'a' => [0.25, 0.25, 0.25, 0.25],
      'b' => [1.0, 2.0, 1.5, 2.0],
      't' => [0.3, 0.3, 0.2, 0.2],
    }
  end

  def odds_histories_data2
    [
      [2.67, 2.67, 4.0, 4.0],
      [2.29, 2.67, 3.56, 3.56],
      [2.29, 3.2,  4.0,  4.0],
      [2.67, 2.67, 4.0,  4.0],
    ]
  end

  # NOT according to odds_histories_data3
  def params_data3
    {
      'a' => [0.2, 0.5, 0.3],
      'b' => [1.0, 2.0, 1.0],
      't' => [0.2, 0.3, 0.1, 0.4],
    }
  end

  def odds_histories_data3
    [
      [3.2,  3.2,  3.2, 3.2],
      [1.6,  2.67, 8.0, 8.0],
      [5.33, 3.2,  1.6, 8.0],
    ]
  end

  # Completely according to odds_histories_data
  def params_data_equilibrium
    {
      'a' => [0.7, 0.1, 0.2],
      'b' => [1.0, 2.0, 1.0],
      't' => [0.2, 0.3, 0.5],
    }
  end

  def odds_histories_data_equilibrium
    [
      [2.4,  2.4,  2.4],
      [2.61, 2.51, 2.19],
      [2.69, 2.50, 2.09],
    ]
  end
end
