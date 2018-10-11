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

ActiveRecord::Schema.define(version: 20181008210955) do

  create_table "notifications", force: :cascade do |t|
    t.string   "summary",     limit: 160
    t.string   "description", limit: 2048
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "notifications", ["created_at"], name: "index_notifications_on_created_at", using: :btree
  add_index "notifications", ["summary"], name: "index_notifications_on_summary", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "notification_id", limit: 4
    t.string   "label",           limit: 15
    t.string   "ip",              limit: 40
    t.datetime "created_at",                 null: false
  end

  add_index "tags", ["ip"], name: "index_tags_on_ip", using: :btree
  add_index "tags", ["label"], name: "index_tags_on_label", using: :btree
  add_index "tags", ["notification_id"], name: "index_tags_on_notification_id", using: :btree

end
