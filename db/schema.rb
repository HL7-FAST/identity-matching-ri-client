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

ActiveRecord::Schema[7.0].define(version: 2022_07_13_185452) do
  create_table "identity_matching_requests", force: :cascade do |t|
    t.string "full_name"
    t.date "date_of_birth"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "email"
    t.string "mobile"
    t.integer "response_status"
    t.text "response_json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patient_servers", force: :cascade do |t|
    t.text "base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
