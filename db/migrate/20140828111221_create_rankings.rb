class CreateRankings < ActiveRecord::Migration
  def change
    create_table :ranking_reports, id: :uuid do |t|
      t.uuid :game_id, null: false
      t.text :original
      t.string :title
      t.string :ranking_type, null: false
      t.string :period, null: false

      t.timestamps
    end

    create_table :ranking_profiles, id: :uuid do |t|
      t.uuid   :game_id, null: false
      t.string :name,              null: false
      t.string :yahoo_player_key

      t.timestamps
    end

    add_index :ranking_profiles, [:game_id, :name], unique: true

    create_table :rankings, id: :uuid do |t|
      t.integer :rank, null: false
      t.string :position
      t.string :team
      t.integer :bye_week
      t.string :best_rank
      t.string :worst_rank
      t.string :ave_rank
      t.string :std_dev
      t.string :adp

      t.uuid :ranking_report_id, null: false
      t.uuid :ranking_profile_id, null: false

      t.timestamps
    end

    add_index :rankings, [:rank, :ranking_report_id], unique: true
    add_index :rankings, [:ranking_profile_id, :ranking_report_id], unique: true
  end
end
