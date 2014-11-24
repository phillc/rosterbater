class CreateMatchups < ActiveRecord::Migration
  def change
    create_table :matchups, id: :uuid do |t|
      t.uuid :league_id, null: false
      t.integer :week
      t.string :status
      t.boolean :is_playoffs
      t.boolean :is_consolation
      t.boolean :is_tied

      t.timestamps
    end

    create_table :matchup_teams, id: :uuid  do |t|
      t.uuid :matchup_id, null: false
      t.string :yahoo_team_key, null: false
      t.boolean :is_winner
      t.decimal :points
      t.decimal :projected_points

      t.timestamps
    end


    add_foreign_key :matchups, :leagues
    add_foreign_key :matchup_teams, :matchups
    add_foreign_key :matchup_teams, :teams,  column: "yahoo_team_key", primary_key: "yahoo_team_key"
    add_index :matchup_teams, [:matchup_id, :yahoo_team_key], unique: true
  end
end
