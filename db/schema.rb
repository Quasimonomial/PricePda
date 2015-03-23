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

ActiveRecord::Schema.define(version: 20150323054301) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",    null: false
  end

  add_index "companies", ["name"], name: "index_companies_on_name", unique: true, using: :btree

  create_table "historical_prices", force: true do |t|
    t.integer  "price_id",                            null: false
    t.integer  "month"
    t.integer  "year"
    t.decimal  "price_value", precision: 7, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "historical_prices", ["month"], name: "index_historical_prices_on_month", using: :btree
  add_index "historical_prices", ["price_id"], name: "index_historical_prices_on_price_id", using: :btree
  add_index "historical_prices", ["year"], name: "index_historical_prices_on_year", using: :btree

  create_table "prices", force: true do |t|
    t.decimal  "price",       precision: 7, scale: 2, null: false
    t.integer  "product_id",                          null: false
    t.integer  "pricer_id",                           null: false
    t.string   "pricer_type",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prices", ["pricer_id", "pricer_type"], name: "index_prices_on_pricer_id_and_pricer_type", using: :btree
  add_index "prices", ["product_id"], name: "index_prices_on_product_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "category",   null: false
    t.string   "dosage"
    t.string   "package"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       null: false
    t.boolean  "enabled",    null: false
  end

  add_index "products", ["category"], name: "index_products_on_category", using: :btree
  add_index "products", ["dosage"], name: "index_products_on_dosage", using: :btree
  add_index "products", ["package"], name: "index_products_on_package", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                                  null: false
    t.string   "password_digest",                        null: false
    t.string   "session_token"
    t.integer  "price_range_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.string   "hospital_name",                          null: false
    t.string   "city",                                   null: false
    t.string   "state",                                  null: false
    t.string   "zip_code",                               null: false
    t.string   "phone"
    t.integer  "comparison_company_id"
    t.boolean  "is_admin"
    t.integer  "permission_level"
    t.string   "activation_digest"
    t.boolean  "activated",              default: false
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "abbreviation"
  end

end
