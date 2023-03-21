# frozen_string_literal: true

module Uma2
  class Proposer
    # Strategy instance class which entries are nonnegative Integer
    class Strategy < Array
      def initialize(src, param_t, odds)
        super(src)
        @t = param_t
        @odds = odds
        validate_params!
      end

      def expectation
        @t.expectation(gain)
      end

      def probability
        @t.expectation(betting)
      end

      def redistribute!(bet, ordered_indices)
        size.times do |i|
          break if sum >= bet

          index = ordered_indices[i]
          self[index] += 1
        end
      end

      def +(other)
        map!.with_index { |s_i, i| s_i + other[i] }
        validate_params!
        self
      end

      private

      def validate_params!
        raise 'param_t must be Uma2::Probability' unless @t.is_a?(Uma2::Probability)

        map! { |s_i| [s_i.to_i, 0].max }
      end

      def gain
        map.with_index { |s_i, i| s_i * @odds[i] }
      end

      def betting
        map { |s_i| s_i.zero? ? 0.0 : 1.0 }
      end
    end
  end
end
