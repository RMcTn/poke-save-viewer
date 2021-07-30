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

ActiveRecord::Schema.define(version: 2021_07_30_081751) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "gen1_boxes", force: :cascade do |t|
    t.bigint "gen1_entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gen1_entry_id"], name: "index_gen1_boxes_on_gen1_entry_id"
  end

  create_table "gen1_entries", force: :cascade do |t|
    t.text "playerName"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "badges", default: [], array: true
    t.integer "playtime"
  end

  create_table "gen1_hall_of_fame_entries", force: :cascade do |t|
    t.bigint "gen1_entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gen1_entry_id"], name: "index_gen1_hall_of_fame_entries_on_gen1_entry_id"
  end

  create_table "gen1_hall_of_fame_pokemons", force: :cascade do |t|
    t.integer "pokemon_id"
    t.integer "level"
    t.string "nickname"
    t.bigint "gen1_hall_of_fame_entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gen1_hall_of_fame_entry_id"], name: "index_gen1_hall_of_fame_pokemons_on_gen1_hall_of_fame_entry_id"
  end

  create_table "gen2_entries", force: :cascade do |t|
    t.text "player_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "playtime"
  end

  create_table "gen2_parties", force: :cascade do |t|
    t.bigint "gen2_entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gen2_entry_id"], name: "index_gen2_parties_on_gen2_entry_id"
  end

  create_table "gen2_pokemons", force: :cascade do |t|
    t.integer "pokemon_id"
    t.integer "current_hp"
    t.integer "status_condition"
    t.integer "type1"
    t.integer "type2"
    t.integer "move1_id"
    t.integer "move2_id"
    t.integer "move3_id"
    t.integer "move4_id"
    t.integer "max_hp"
    t.integer "level"
    t.string "nickname"
    t.bigint "gen2_party_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gen2_party_id"], name: "index_gen2_pokemons_on_gen2_party_id"
  end

  create_table "parties", force: :cascade do |t|
    t.bigint "gen1_entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gen1_entry_id"], name: "index_parties_on_gen1_entry_id"
  end

  create_table "pokemons", force: :cascade do |t|
    t.integer "pokemon_id"
    t.integer "current_hp"
    t.integer "status_condition"
    t.integer "type1"
    t.integer "type2"
    t.integer "move1_id"
    t.integer "move2_id"
    t.integer "move3_id"
    t.integer "move4_id"
    t.integer "max_hp"
    t.integer "level"
    t.string "nickname"
    t.bigint "party_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "gen1_box_id"
    t.index ["gen1_box_id"], name: "index_pokemons_on_gen1_box_id"
    t.index ["party_id"], name: "index_pokemons_on_party_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "gen1_boxes", "gen1_entries"
  add_foreign_key "gen1_hall_of_fame_entries", "gen1_entries"
  add_foreign_key "gen1_hall_of_fame_pokemons", "gen1_hall_of_fame_entries"
  add_foreign_key "gen2_parties", "gen2_entries"
  add_foreign_key "gen2_pokemons", "gen2_parties"
  add_foreign_key "parties", "gen1_entries"
  add_foreign_key "pokemons", "gen1_boxes"
  add_foreign_key "pokemons", "parties"
end
