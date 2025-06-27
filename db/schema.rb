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

ActiveRecord::Schema[8.0].define(version: 2025_06_26_214024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.string "created_by_type", null: false
    t.bigint "created_by_id", null: false
    t.bigint "ticket_id", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_type", "created_by_id"], name: "index_comments_on_created_by"
    t.index ["created_by_type", "created_by_id"], name: "index_comments_on_created_by_type_and_created_by_id"
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.bigint "created_by_id", null: false
    t.bigint "assigned_to_id"
    t.datetime "deadline"
    t.string "status", default: "ACTIVE", null: false
    t.boolean "has_user_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "media", default: [], array: true
    t.text "ticket_key"
    t.index ["assigned_to_id"], name: "index_tickets_on_assigned_to_id"
    t.index ["created_by_id"], name: "index_tickets_on_created_by_id"
    t.index ["deadline"], name: "index_tickets_on_deadline"
    t.index ["status"], name: "index_tickets_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "comments", "tickets"
  add_foreign_key "tickets", "agents", column: "assigned_to_id", on_delete: :nullify
  add_foreign_key "tickets", "users", column: "created_by_id"
end
