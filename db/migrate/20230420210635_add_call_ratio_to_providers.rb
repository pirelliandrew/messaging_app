# frozen_string_literal: true

class AddCallRatioToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :call_ratio, :integer, default: 100, null: false
  end
end
