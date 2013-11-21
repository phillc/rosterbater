class CreateManagers < ActiveRecord::Migration
  def change
    create_table :managers, id: :uuid do |t|
      t.string :guid
      t.integer :yahoo_manager_id, null: false
      t.string :nickname
      t.boolean :is_commissioner
      t.uuid :team_id
      t.uuid :user_id

      t.timestamps
    end
  end
end
