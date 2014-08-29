class CreateDraftPicks < ActiveRecord::Migration
  def change
    create_table :draft_picks, id: :uuid do |t|
      t.integer :pick,             null: false
      t.integer :round,            null: false
      t.string  :yahoo_team_key,   null: false
      t.string  :yahoo_player_key, null: false

      t.uuid :league_id, null: false

      t.timestamps
    end

    add_index :draft_picks, [:league_id, :pick], unique: true
  end
end
