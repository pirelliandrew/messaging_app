# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_04_20_184030) do
  create_table "messages", force: :cascade do |t|
    t.string "message_id", null: false
    t.string "delivery_status", null: false
    t.integer "phone_id", null: false
    t.integer "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_messages_on_message_id", unique: true
    t.index ["phone_id"], name: "index_messages_on_phone_id"
    t.index ["provider_id"], name: "index_messages_on_provider_id"
  end

  create_table "phones", force: :cascade do |t|
    t.string "number", limit: 10, null: false
    t.boolean "blacklist", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_phones_on_number", unique: true
  end

  create_table "providers", force: :cascade do |t|
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "index_providers_on_url", unique: true
  end

  add_foreign_key "messages", "phones"
  add_foreign_key "messages", "providers"
end
