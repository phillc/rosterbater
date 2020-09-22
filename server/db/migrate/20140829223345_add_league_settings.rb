class AddLeagueSettings < ActiveRecord::Migration[4.2]
  def change
    change_table :leagues do |t|
      t.boolean :is_auction_draft
      t.datetime :trade_end_date
      t.json :settings
    end
  end
end
