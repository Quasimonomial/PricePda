# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150223090557) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
  end

  create_table "historical_prices", force: true do |t|
    t.integer "price_id",                         null: false
    t.integer "month"
    t.integer "year"
    t.decimal "price",    precision: 7, scale: 2, null: false
  end

  add_index "historical_prices", ["month"], name: "index_historical_prices_on_month", using: :btree
  add_index "historical_prices", ["price_id"], name: "index_historical_prices_on_price_id", using: :btree
  add_index "historical_prices", ["year"], name: "index_historical_prices_on_year", using: :btree

  create_table "prices", force: true do |t|
    t.decimal  "price",       precision: 7, scale: 2, null: false
    t.integer  "product_id"
    t.integer  "pricer_id"
    t.string   "pricer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "string"
    t.integer  "integer"
  end

  create_table "products", force: true do |t|
    t.string   "category"
    t.string   "dosage"
    t.string   "package"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "enabled"
  end

  add_index "products", ["category"], name: "index_products_on_category", using: :btree
  add_index "products", ["dosage"], name: "index_products_on_dosage", using: :btree
  add_index "products", ["package"], name: "index_products_on_package", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "session_token"
    t.integer  "price_range_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "hospital_name"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "phone"
    t.integer  "comparison_company_id"
    t.boolean  "is_admin"
  end

end
