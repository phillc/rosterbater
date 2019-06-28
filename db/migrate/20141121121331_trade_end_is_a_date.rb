class TradeEndIsADate < ActiveRecord::Migration[4.2]
  def change
    change_column :leagues, :trade_end_date, :date
  end
end
