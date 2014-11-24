class TradeEndIsADate < ActiveRecord::Migration
  def change
    change_column :leagues, :trade_end_date, :date
  end
end
