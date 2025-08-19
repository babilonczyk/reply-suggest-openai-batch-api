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

ActiveRecord::Schema[8.0].define(version: 2025_08_19_104039) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "email_submissions", force: :cascade do |t|
    t.string "email"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submission_batches", force: :cascade do |t|
    t.string "batch_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.text "content"
    t.text "generated_reply"
    t.string "status", null: false
    t.text "review_comment"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "submission_batch_id"
    t.index ["submission_batch_id"], name: "index_submissions_on_submission_batch_id"
  end
end
