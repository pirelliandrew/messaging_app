# frozen_string_literal: true

class CreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers do |t|
      t.string :url, null: false

      t.timestamps

      t.index :url, unique: true
    end
  end
end
