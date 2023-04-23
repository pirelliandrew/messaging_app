# frozen_string_literal: true

class AddCallCountToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :call_count, :integer, default: 0, null: false
  end
end
