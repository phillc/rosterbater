class DraftPickPlayerCanBeNull < ActiveRecord::Migration
  def change
    change_column :draft_picks, :yahoo_player_key, :string, null: true
  end
end
