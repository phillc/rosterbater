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

ActiveRecord::Schema.define(version: 20131120014504) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "managers", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "guid"
    t.integer  "yahoo_manager_id", null: false
    t.string   "nickname"
    t.boolean  "is_commissioner"
    t.uuid     "team_id"
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.integer  "yahoo_game_key"
    t.integer  "yahoo_league_id"
    t.integer  "yahoo_team_id"
    t.integer  "yahoo_division_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "provider"
    t.string   "email"
    t.string   "uid"
    t.string   "name"
    t.text     "yahoo_token"
    t.string   "yahoo_token_secret"
    t.string   "yahoo_session_handle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
