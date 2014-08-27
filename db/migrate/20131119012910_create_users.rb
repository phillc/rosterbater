class CreateUsers < ActiveRecord::Migration
  def change
    enable_extension :"uuid-ossp"

    create_table :users, id: :uuid  do |t|
      t.string :provider
      t.string :email
      t.string :yahoo_uid, null: false
      t.string :name
      t.text   :yahoo_token
      t.string :yahoo_token_secret
      t.string :yahoo_session_handle

      t.timestamps
    end

    add_index :users, :yahoo_uid, unique: true
  end
end
