# frozen_string_literal: true

class CreatePhones < ActiveRecord::Migration[7.0]
  def change
    create_table :phones do |t|
      t.string :number, limit: 10, null: false
      t.boolean :blacklist, null: false, default: false

      t.timestamps

      t.index :number, unique: true
    end
  end
end
