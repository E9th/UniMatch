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

ActiveRecord::Schema[8.1].define(version: 2026_02_07_200002) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chat_room_memberships", force: :cascade do |t|
    t.integer "chat_room_id", null: false
    t.datetime "created_at", null: false
    t.boolean "identity_revealed", default: false, null: false
    t.datetime "last_read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["chat_room_id"], name: "index_chat_room_memberships_on_chat_room_id"
    t.index ["user_id"], name: "index_chat_room_memberships_on_user_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_ai_mode"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_chat_rooms_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "chat_room_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "chat_room_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.integer "reviewee_id", null: false
    t.integer "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_reviews_on_chat_room_id"
    t.index ["reviewee_id"], name: "index_reviews_on_reviewee_id"
    t.index ["reviewer_id", "chat_room_id"], name: "index_reviews_on_reviewer_id_and_chat_room_id", unique: true
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "available_time"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "faculty"
    t.string "name"
    t.string "password_digest"
    t.string "strong_subject"
    t.string "study_style"
    t.datetime "updated_at", null: false
    t.string "weak_subject"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_room_memberships", "chat_rooms"
  add_foreign_key "chat_room_memberships", "users"
  add_foreign_key "chat_rooms", "users"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "reviews", "chat_rooms"
  add_foreign_key "reviews", "users", column: "reviewee_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
end
