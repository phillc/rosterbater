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

ActiveRecord::Schema.define(version: 20140928202118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "draft_picks", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.integer  "pick",             null: false
    t.integer  "round",            null: false
    t.string   "yahoo_team_key",   null: false
    t.string   "yahoo_player_key", null: false
    t.uuid     "league_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost"
    t.integer  "auction_pick"
  end

  add_index "draft_picks", ["league_id", "pick"], name: "index_draft_picks_on_league_id_and_pick", unique: true, using: :btree

  create_table "games", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.integer  "yahoo_game_key", null: false
    t.integer  "yahoo_game_id",  null: false
    t.string   "name",           null: false
    t.string   "code",           null: false
    t.string   "game_type"
    t.string   "url"
    t.integer  "season",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "games", ["code", "season"], name: "index_games_on_code_and_season", unique: true, using: :btree
  add_index "games", ["yahoo_game_id"], name: "index_games_on_yahoo_game_id", unique: true, using: :btree
  add_index "games", ["yahoo_game_key"], name: "index_games_on_yahoo_game_key", unique: true, using: :btree

  create_table "leagues", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name",                                 null: false
    t.string   "yahoo_league_key",                     null: false
    t.integer  "yahoo_league_id",                      null: false
    t.string   "url"
    t.integer  "num_teams"
    t.string   "scoring_type"
    t.string   "renew"
    t.string   "renewed"
    t.integer  "current_week"
    t.integer  "start_week"
    t.integer  "end_week"
    t.date     "start_date"
    t.date     "end_date"
    t.uuid     "game_id",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sync_finished_at"
    t.boolean  "is_auction_draft"
    t.datetime "trade_end_date"
    t.json     "settings"
    t.datetime "sync_started_at"
    t.boolean  "has_finished_draft",   default: false, null: false
    t.decimal  "points_per_reception", default: 0.0,   null: false
  end

  add_index "leagues", ["yahoo_league_key"], name: "index_leagues_on_yahoo_league_key", unique: true, using: :btree

  create_table "leagues_users", id: false, force: true do |t|
    t.uuid "league_id"
    t.uuid "user_id"
  end

  add_index "leagues_users", ["league_id", "user_id"], name: "index_leagues_users_on_league_id_and_user_id", unique: true, using: :btree

  create_table "managers", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.string   "image_url"
    t.string   "yahoo_guid"
    t.boolean  "is_commissioner"
    t.string   "email"
    t.uuid     "team_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "managers", ["yahoo_guid", "team_id"], name: "index_managers_on_yahoo_guid_and_team_id", unique: true, using: :btree

  create_table "players", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "yahoo_player_key",                      null: false
    t.string   "yahoo_player_id",                       null: false
    t.string   "full_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "ascii_first_name"
    t.string   "ascii_last_name"
    t.string   "status"
    t.string   "editorial_player_key"
    t.string   "editorial_team_key"
    t.string   "editorial_team_full_name"
    t.string   "editorial_team_abbr"
    t.text     "bye_weeks",                default: [],              array: true
    t.string   "uniform_number"
    t.string   "display_position"
    t.string   "image_url"
    t.boolean  "is_undroppable"
    t.string   "position_type"
    t.text     "eligible_positions",       default: [],              array: true
    t.boolean  "has_player_notes"
    t.string   "draft_average_pick"
    t.string   "draft_average_round"
    t.string   "draft_average_cost"
    t.string   "draft_percent_drafted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "game_id",                               null: false
  end

  add_index "players", ["yahoo_player_key"], name: "index_players_on_yahoo_player_key", unique: true, using: :btree

  create_table "ranking_profiles", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "game_id",          null: false
    t.string   "name",             null: false
    t.string   "yahoo_player_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ranking_profiles", ["game_id", "name"], name: "index_ranking_profiles_on_game_id_and_name", unique: true, using: :btree

  create_table "ranking_reports", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "game_id",      null: false
    t.text     "original"
    t.string   "title"
    t.string   "ranking_type", null: false
    t.string   "period",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rankings", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.integer  "rank",               null: false
    t.string   "position"
    t.string   "team"
    t.integer  "bye_week"
    t.string   "best_rank"
    t.string   "worst_rank"
    t.string   "ave_rank"
    t.string   "std_dev"
    t.string   "adp"
    t.uuid     "ranking_report_id",  null: false
    t.uuid     "ranking_profile_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rankings", ["rank", "ranking_report_id"], name: "index_rankings_on_rank_and_ranking_report_id", unique: true, using: :btree
  add_index "rankings", ["ranking_profile_id", "ranking_report_id"], name: "index_rankings_on_ranking_profile_id_and_ranking_report_id", unique: true, using: :btree

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
    t.datetime "sync_finished_at"
    t.datetime "sync_started_at"
  end

  add_index "users", ["yahoo_uid"], name: "index_users_on_yahoo_uid", unique: true, using: :btree

  add_foreign_key "draft_picks", "leagues", name: "draft_picks_league_id_fk"
  add_foreign_key "draft_picks", "players", name: "draft_picks_yahoo_player_key_fk", column: "yahoo_player_key", primary_key: "yahoo_player_key"
  add_foreign_key "draft_picks", "teams", name: "draft_picks_yahoo_team_key_fk", column: "yahoo_team_key", primary_key: "yahoo_team_key"

  add_foreign_key "leagues", "games", name: "leagues_game_id_fk"

  add_foreign_key "leagues_users", "leagues", name: "leagues_users_league_id_fk"
  add_foreign_key "leagues_users", "users", name: "leagues_users_user_id_fk"

  add_foreign_key "managers", "teams", name: "managers_team_id_fk"

  add_foreign_key "players", "games", name: "players_game_id_fk"

  add_foreign_key "ranking_profiles", "games", name: "ranking_profiles_game_id_fk"
  add_foreign_key "ranking_profiles", "players", name: "ranking_profiles_yahoo_player_key_fk", column: "yahoo_player_key", primary_key: "yahoo_player_key"

  add_foreign_key "ranking_reports", "games", name: "ranking_reports_game_id_fk"

  add_foreign_key "rankings", "ranking_profiles", name: "rankings_ranking_profile_id_fk"
  add_foreign_key "rankings", "ranking_reports", name: "rankings_ranking_report_id_fk"

  add_foreign_key "teams", "leagues", name: "teams_league_id_fk"

end
