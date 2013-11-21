class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams, id: :uuid do |t|
      t.string :name
      t.integer :yahoo_game_key
      t.integer :yahoo_league_id
      t.integer :yahoo_team_id
      t.integer :yahoo_division_id
      t.string :url

      t.timestamps
    end
  end
end
