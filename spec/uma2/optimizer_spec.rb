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
      let(:params) { params_data }
      it 'takes over give parameters' do
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
    before { @optimizer = Uma2::Optimizer.new(params: params_data) }
    subject { @optimizer.add_odds(odds_histories) }

    context 'with larger odds histories than optimizer size' do
      let(:odds_histories) { odds_histories_data }
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
      let(:odds_histories) { odds_histories_data }

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
      @optimizer = Uma2::Optimizer.new(params: params_data)
      @optimizer.add_odds(odds_histories_data)
    end
    subject { @optimizer.run(iteration) }

    let(:iteration) { 10 }
    context 'for 10 iteration' do
      before { allow(@optimizer).to receive(:update!).and_return(1) }
      it 'calls #update! 10 times' do
        subject
        expect(@optimizer).to have_received(:update!).exactly(iteration).times
      end
    end
  end

  describe '#loss' do
    before do
      @optimizer = Uma2::Optimizer.new(params: params_data)
      @optimizer.add_odds(odds_histories_data)
      @optimizer.run(1)
    end
    subject { @optimizer.loss }

    it 'gives a positive value' do
      is_expected.to be > 0.1
    end

    it 'gives the same values in another updates' do
      old_loss = @optimizer.loss
      is_expected.to be_within(1e-5).of(old_loss)
    end

    xit 'decreases loss function' do
      old_loss = @optimizer.loss
      @optimizer.run(1)
      is_expected.to be < old_loss
    end
  end

  def params_data
    {
      'a' => [0.2, 0.8],
      'b' => [1.0, 2.0],
      't' => [0.2, 0.3, 0.5],
    }
  end

  def odds_histories_data
    [
      [3.2,  3.2,  1.6],
      [4.0,  2.67, 1.6],
      [5.33, 2.67, 1.45],
      [5.33, 2.29, 1.6],
    ]
  end
end
