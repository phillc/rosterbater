class CreateGames < ActiveRecord::Migration
  def change
    create_table :games, id: :uuid do |t|
      t.integer :yahoo_game_key, null: false
      t.integer :yahoo_game_id,  null: false
      t.string :name,            null: false
      t.string :code,            null: false
      t.string :game_type
      t.string :url
      t.integer :season,         null: false

      t.timestamps
    end

    add_index :games, :yahoo_game_key, unique: true
    add_index :games, :yahoo_game_id, unique: true
    add_index :games, [:code, :season], unique: true
  end
end
