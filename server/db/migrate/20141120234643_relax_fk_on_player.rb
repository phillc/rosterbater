class RelaxFkOnPlayer < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key "draft_picks", name: "draft_picks_yahoo_player_key_fk"
  end
end
