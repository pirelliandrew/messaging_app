# frozen_string_literal: true

module Provider
  class Select < ActiveInteraction::Base
    array :failed_providers, default: []

    def execute
      # 4. Retrieve provider call counts
      provider_data = Provider.retrieve_provider_data(failed_providers)
      # 5. Determine which SMS provider to call
      Provider.select_provider_by_call_ratio(provider_data)
    end

    private

    def retrieve_provider_data
      total_call_count = Provider.sum(:call_count)

      Provider
        .where
        .not(id: failed_providers.pluck(:id))
        .pluck(:id, :call_count, :call_ratio)
        .map do |id, call_count, call_ratio|
        current_call_ratio = call_count / total_call_count
        call_ratio_difference = current_call_ratio - call_ratio

        [id, call_ratio_difference]
      end
    end

    def select_provider_by_call_ratio(provider_data)
      smallest_call_ratio_difference = 100
      selected_provider_id = nil

      provider_data.each do |id, call_ratio_difference|
        if call_ratio_difference < smallest_call_ratio_difference
          smallest_call_ratio_difference = call_ratio_difference
          selected_provider_id = id
        end
      end

      Provider.find(selected_provider_id)
    end
  end
end
