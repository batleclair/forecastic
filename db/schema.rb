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

ActiveRecord::Schema[7.0].define(version: 2024_10_31_090657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.bigint "period_id", null: false
    t.bigint "metric_id", null: false
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "dependents", default: [], array: true
    t.float "calc"
    t.date "date"
    t.string "formula_body"
    t.index ["metric_id"], name: "index_entries_on_metric_id"
    t.index ["period_id"], name: "index_entries_on_period_id"
  end

  create_table "formulas", force: :cascade do |t|
    t.bigint "metric_id", null: false
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_id"], name: "index_formulas_on_metric_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fixed"
    t.index ["project_id"], name: "index_metrics_on_project_id"
  end

  create_table "periods", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_periods_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "values", default: {}
    t.integer "periodicity", default: 1
    t.date "first_end", default: "2024-12-01"
  end

  create_table "rows", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.bigint "metric_id", null: false
    t.integer "position"
    t.boolean "anchor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_id"], name: "index_rows_on_metric_id"
    t.index ["section_id"], name: "index_rows_on_section_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.bigint "sheet_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sheet_id"], name: "index_sections_on_sheet_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_sheets_on_project_id"
  end

  add_foreign_key "entries", "metrics"
  add_foreign_key "entries", "periods"
  add_foreign_key "formulas", "metrics"
  add_foreign_key "metrics", "projects"
  add_foreign_key "periods", "projects"
  add_foreign_key "rows", "metrics"
  add_foreign_key "rows", "sections"
  add_foreign_key "sections", "sheets"
  add_foreign_key "sheets", "projects"
end
