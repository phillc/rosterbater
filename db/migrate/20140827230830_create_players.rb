class CreatePlayers < ActiveRecord::Migration[4.2]
  def change
    create_table :players, id: :uuid do |t|
      t.string :yahoo_player_key, null: false
      t.string :yahoo_player_id, null: false
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.string :ascii_first_name
      t.string :ascii_last_name
      t.string :status
      t.string :editorial_player_key
      t.string :editorial_team_key
      t.string :editorial_team_full_name
      t.string :editorial_team_abbr
      t.text :bye_weeks, array: true, default: []
      t.string :uniform_number
      t.string :display_position
      t.string :image_url
      t.boolean :is_undroppable
      t.string :position_type
      t.text :eligible_positions, array: true, default: []
      t.boolean :has_player_notes
      t.string :draft_average_pick
      t.string :draft_average_round
      t.string :draft_average_cost
      t.string :draft_percent_drafted

      t.timestamps

      t.uuid :game_id, null: false
    end

    add_index :players, :yahoo_player_key, unique: true
  end
end
