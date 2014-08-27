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

ActiveRecord::Schema.define(version: 20140824152040) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "leagues", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string  "name",             null: false
    t.string  "yahoo_league_key", null: false
    t.integer "yahoo_league_id",  null: false
    t.string  "url"
    t.integer "num_teams"
    t.string  "scoring_type"
    t.string  "renew"
    t.string  "renewed"
    t.integer "current_week"
    t.integer "start_week"
    t.integer "end_week"
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "leagues", ["yahoo_league_key"], name: "index_leagues_on_yahoo_league_key", unique: true, using: :btree

  create_table "leagues_users", id: false, force: true do |t|
    t.uuid "league_id"
    t.uuid "user_id"
  end

  add_index "leagues_users", ["league_id", "user_id"], name: "index_leagues_users_on_league_id_and_user_id", unique: true, using: :btree

  create_table "managers", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string  "name"
    t.string  "image_url"
    t.string  "yahoo_guid"
    t.boolean "is_commissioner"
    t.string  "email"
    t.uuid    "team_id",         null: false
  end

  add_index "managers", ["yahoo_guid", "team_id"], name: "index_managers_on_yahoo_guid_and_team_id", unique: true, using: :btree

  create_table "teams", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name",             null: false
    t.string   "yahoo_team_key",   null: false
    t.integer  "yahoo_team_id",    null: false
    t.string   "url"
    t.string   "logo_url"
    t.integer  "waiver_priority"
    t.integer  "faab_balance"
    t.integer  "number_of_moves"
    t.integer  "number_of_trades"
    t.uuid     "league_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["yahoo_team_key"], name: "index_teams_on_yahoo_team_key", unique: true, using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "provider"
    t.string   "email"
    t.string   "yahoo_uid",            null: false
    t.string   "name"
    t.text     "yahoo_token"
    t.string   "yahoo_token_secret"
    t.string   "yahoo_session_handle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["yahoo_uid"], name: "index_users_on_yahoo_uid", unique: true, using: :btree

end
