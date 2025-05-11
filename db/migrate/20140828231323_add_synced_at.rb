class AddSyncedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :users,   :synced_at, :datetime
    add_column :leagues, :synced_at, :datetime
  end
end
