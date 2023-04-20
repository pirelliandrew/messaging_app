class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :message_id, null: false
      t.string :delivery_status, null: false
      t.references :phone, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true

      t.timestamps

      t.index :message_id, unique: true
    end
  end
end
