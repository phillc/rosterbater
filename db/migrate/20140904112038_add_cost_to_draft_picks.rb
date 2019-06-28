class AddCostToDraftPicks < ActiveRecord::Migration[4.2]
  def change
    change_table :draft_picks do |t|
      t.integer :cost
      t.integer :auction_pick
    end
  end
end
