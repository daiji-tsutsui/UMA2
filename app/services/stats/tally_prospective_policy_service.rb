# frozen_string_literal: true

module Stats
  # Service object class which tallies race results with prospective policy
  class TallyProspectivePolicyService < TallyService
    private

    def targets(date)
      targets_base = super(date)
      targets_base.select do |race|
        proposer(race).gain_strategy.expected_gain.positive?
      end
    end

    def format(result)
      {
        pp_gain_actual:   result[0],
        pp_gain_expected: result[1],
        pp_hit_actual:    result[2],
        pp_hit_expected:  result[3],
        pp_gain_total:    result[4],
        pp_hit_total:     result[6],
        target_size:      result[8],
      }
    end
  end
end
