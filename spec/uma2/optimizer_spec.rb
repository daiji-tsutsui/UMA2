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
        expect(@optimizer.a.class).to eq Uma2::Optimizer::Weight
        expect(@optimizer.b.class).to eq Uma2::Optimizer::Certainty
        expect(@optimizer.t.class).to eq Uma2::Optimizer::TrueDistribution
      end
    end

    context 'with params' do
      let(:params) do
        {
          'a' => [0.2, 0.8],
          'b' => [1.0, 2.0],
          't' => [0.2, 0.3, 0.5],
        }
      end
      it 'takes over give parameters' do
        subject
        expect(@optimizer.a.class).to eq Uma2::Optimizer::Weight
        expect(@optimizer.b.class).to eq Uma2::Optimizer::Certainty
        expect(@optimizer.t.class).to eq Uma2::Optimizer::TrueDistribution
        expect(@optimizer.a).to eq [0.2, 0.8]
        expect(@optimizer.b).to eq [1.0, 2.0]
        expect(@optimizer.t).to eq [0.2, 0.3, 0.5]
      end
    end
  end

  describe '#add_odds' do
    before do
      params = {
        'a' => [0.2, 0.8],
        'b' => [1.0, 2.0],
        't' => [0.2, 0.3, 0.5],
      }
      @optimizer = Uma2::Optimizer.new(params: params)
    end
    subject { @optimizer.add_odds(odds_histories) }

    context 'with larger odds histories than optimizer size' do
      let(:odds_histories) do
        [
          [3.2,  3.2,  1.6],
          [4.0,  2.67, 1.6],
          [5.33, 2.67, 1.45],
          [5.33, 2.29, 1.6],
        ]
      end
      it 'extends optimizer size to odds histories size' do
        expect { subject }.to change { @optimizer.a.size }.by(2)
        expect(@optimizer.b.size).to eq 4
        expect(@optimizer.t.size).to eq 3
      end
    end

    context 'with smaller odds histories than optimizer size' do
      let(:odds_histories) do
        [
          [3.2, 3.2, 1.6],
        ]
      end
      it 'does NOT change optimizer size' do
        expect { subject }.to_not(change { @optimizer.a.size })
        expect(@optimizer.b.size).to eq 2
        expect(@optimizer.t.size).to eq 3
      end
    end

    context 'if optimizer has no params' do
      before { @optimizer = Uma2::Optimizer.new }
      let(:odds_histories) do
        [
          [3.2, 3.2, 1.6],
        ]
      end
      it 'extends true distribution size' do
        expect { subject }.to change { @optimizer.t.size }.by(2)
        expect(@optimizer.a.size).to eq 1
        expect(@optimizer.b.size).to eq 1
        expect(@optimizer.t.size).to eq 3
      end
    end
  end

  # xdescribe '#run' do
  #   before do
  #     params = {
  #       'a' => [0.2, 0.8],
  #       'b' => [1.0, 2.0],
  #       't' => [0.2, 0.3, 0.5],
  #     }
  #     @optimizer = Uma2::Optimizer.new(params: params)
  #   end
  #   subject { @optimizer.run(iteration) }

  #   xcontext 'with larger odds histories than optimizer size' do
  #     let(:odds_histories) do
  #       [
  #         [3.2,  3.2,  1.6],
  #         [4.0,  2.67, 1.6],
  #         [5.33, 2.67, 1.45],
  #         [5.33, 2.29, 1.6],
  #       ]
  #     end
  #     it 'extends optimizer size to odds histories size' do
  #       expect { subject }.to change { @optimizer.params[:a].size }.by(2)
  #       expect(@optimizer.params[:b].size).to eq 4
  #       expect(@optimizer.params[:t].size).to eq 3
  #     end
  #   end
  # end
end
