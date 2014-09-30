class AddKeys < ActiveRecord::Migration
  def change
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
end
