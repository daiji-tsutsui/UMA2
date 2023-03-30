# frozen_string_literal: true

require 'uma2/proposer/strategy'

module Uma2
  class Proposer
    # Distributed strategy which entries are nonnegative Float
    class Distribution < Strategy
      def probability; end

      private

      def validate_params!
        raise 'param_t must be Uma2::Probability' unless @t.is_a?(Uma2::Probability)

        map! { |s_i| [s_i, 0.0].max }
      end
    end
  end
end
