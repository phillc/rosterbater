class Oauth2 < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.remove :yahoo_token_secret
      t.remove :yahoo_session_handle
      t.string :yahoo_refresh_token
      t.timestamp :yahoo_expires_at
    end
  end
end
