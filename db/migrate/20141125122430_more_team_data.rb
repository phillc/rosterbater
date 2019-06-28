class MoreTeamData < ActiveRecord::Migration[4.2]
  def change
    change_table :teams do |t|
      t.boolean :has_clinched_playoffs
      t.decimal :points_for
      t.decimal :points_against
      t.integer :rank
      t.integer :wins
      t.integer :losses
      t.integer :ties
    end

    add_column :leagues, :num_playoff_teams, :integer
    add_column :leagues, :num_playoff_consolation_teams, :integer
  end
end
