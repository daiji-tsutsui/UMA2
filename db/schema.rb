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

ActiveRecord::Schema[7.0].define(version: 2022_10_19_132000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_courses_on_name", unique: true
  end

  create_table "race_classes", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_race_classes_on_name", unique: true
  end

  create_table "race_dates", force: :cascade do |t|
    t.date "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value"], name: "index_race_dates_on_value", unique: true
  end

  create_table "races", force: :cascade do |t|
    t.text "name", null: false
    t.bigint "race_date_id"
    t.bigint "course_id"
    t.integer "number", null: false
    t.bigint "race_class_id"
    t.text "weather"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_races_on_course_id"
    t.index ["race_class_id"], name: "index_races_on_race_class_id"
    t.index ["race_date_id"], name: "index_races_on_race_date_id"
  end

  add_foreign_key "races", "courses"
  add_foreign_key "races", "race_classes"
  add_foreign_key "races", "race_dates"
end
