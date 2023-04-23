# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :message_id, null: false
      t.string :state, null: false, default: 'pending'
      t.references :phone, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true

      t.timestamps

      t.index %i[message_id provider_id], unique: true, name: 'index_messages_on_message_id_and_provider'
    end
  end
end
