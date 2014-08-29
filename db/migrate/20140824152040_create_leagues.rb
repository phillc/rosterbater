class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues, id: :uuid do |t|
      t.string  :name,             null: false
      t.string  :yahoo_league_key, null: false
      t.integer :yahoo_league_id,  null: false
      t.string  :url
      t.integer :num_teams
      t.string  :scoring_type
      t.string  :renew
      t.string  :renewed
      t.integer :current_week
      t.integer :start_week
      t.integer :end_week
      t.date    :start_date
      t.date    :end_date

      t.uuid :game_id, null: false

      t.timestamps
    end

    add_index :leagues, :yahoo_league_key, unique: true

    create_table :leagues_users, id: false do |t|
      t.uuid :league_id
      t.uuid :user_id
    end

    add_index :leagues_users, [:league_id, :user_id], unique: true
  end
end
