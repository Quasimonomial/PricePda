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

ActiveRecord::Schema.define(version: 20141211192839) do

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", force: true do |t|
    t.integer  "price"
    t.integer  "product_id"
    t.integer  "pricer_id"
    t.string   "pricer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "category"
    t.string   "product"
    t.string   "dosage"
    t.string   "package"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["category"], name: "index_products_on_category"
  add_index "products", ["dosage"], name: "index_products_on_dosage"
  add_index "products", ["package"], name: "index_products_on_package"
  add_index "products", ["product"], name: "index_products_on_product"

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "session_token"
    t.integer  "price_range_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
