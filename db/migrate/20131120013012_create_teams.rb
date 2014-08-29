class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams, id: :uuid do |t|
      t.string  :name,           null: false
      t.string  :yahoo_team_key, null: false
      t.integer :yahoo_team_id,  null: false
      t.string  :url
      t.string  :logo_url
      t.integer :waiver_priority
      t.integer :faab_balance
      t.integer :number_of_moves
      t.integer :number_of_trades

      t.uuid :league_id, null: false

      t.timestamps
    end

    add_index :teams, :yahoo_team_key, unique: true

    create_table :managers, id: :uuid do |t|
      t.string :name
      t.string :image_url
      t.string :yahoo_guid
      t.boolean :is_commissioner
      t.string :email

      t.uuid :team_id, null: false

      t.timestamps
    end

    add_index :managers, [:yahoo_guid, :team_id], unique: true
  end
end
