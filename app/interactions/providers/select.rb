# frozen_string_literal: true

module Providers
  class Select < ActiveInteraction::Base
    array :failed_providers, default: []

    def execute
      select_provider_by_call_ratio
    end

    private

    def select_provider_by_call_ratio
      providers = Provider.where.not(id: failed_providers.pluck(:id))
      total_call_count = providers.sum(&:call_count)
      total_call_count = 1 if total_call_count.zero?
      total_ratio = providers.sum(&:call_ratio)

      ratio_differences = providers.map do |provider|
        actual_ratio = provider.call_count.to_f / total_call_count
        desired_ratio = provider.call_ratio.to_f / total_ratio
        {
          id: provider.id,
          difference: actual_ratio - desired_ratio
        }
      end

      largest_difference = ratio_differences.min_by { |provider| provider[:difference] }

      Provider.find(largest_difference[:id])
    end
  end
end
