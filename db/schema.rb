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

ActiveRecord::Schema.define(version: 2020_03_26_225427) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brand_variations", force: :cascade do |t|
    t.string "name"
    t.bigint "brand_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_brand_variations_on_brand_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.string "logo"
    t.string "store_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.string "img"
    t.string "coupon"
    t.string "link"
    t.integer "clicks"
    t.bigint "suplemento_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "updated", default: false
    t.boolean "online", default: false
    t.integer "price"
    t.integer "last_day_clicks", default: 0
    t.index ["suplemento_id"], name: "index_posts_on_suplemento_id"
  end

  create_table "prices", force: :cascade do |t|
    t.integer "price"
    t.bigint "suplemento_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["suplemento_id"], name: "index_prices_on_suplemento_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo"
  end

  create_table "sup_posts", force: :cascade do |t|
    t.bigint "suplemento_id"
    t.bigint "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_sup_posts_on_post_id"
    t.index ["suplemento_id"], name: "index_sup_posts_on_suplemento_id"
  end

  create_table "suplementos", force: :cascade do |t|
    t.string "name"
    t.string "link"
    t.string "seller"
    t.string "sender"
    t.string "weight"
    t.string "flavor"
    t.string "store_code"
    t.boolean "price_changed?"
    t.string "brand"
    t.bigint "store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "photo"
    t.boolean "price_changed"
    t.boolean "prime"
    t.boolean "supershipping"
    t.string "promo"
    t.integer "average"
    t.integer "diff"
    t.string "ean"
    t.string "category"
    t.string "subcategory"
    t.string "combo"
    t.integer "auxgrad"
    t.boolean "checked", default: false
    t.integer "dependants", default: 0
    t.string "brand_code"
    t.index ["store_id"], name: "index_suplementos_on_store_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token"
    t.index ["authentication_token"], name: "index_users_on_authentication_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "brand_variations", "brands"
  add_foreign_key "posts", "suplementos"
  add_foreign_key "prices", "suplementos"
  add_foreign_key "sup_posts", "posts"
  add_foreign_key "sup_posts", "suplementos"
  add_foreign_key "suplementos", "stores"
end
