class MoveStuffAround < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  class Ranking < ActiveRecord::Base; end
  class DraftPick < ActiveRecord::Base; end
  class League < ActiveRecord::Base
    has_many :draft_picks
  end

  def change
    RankingReport.where(ranking_type: "half_point").update_all ranking_type: "half_ppr"

    rename_column :leagues, :synced_at, :sync_finished_at
    add_column :leagues, :sync_started_at, :datetime
    rename_column :users, :synced_at, :sync_finished_at
    add_column :users, :sync_started_at, :datetime

    add_column :leagues, :has_finished_draft, :boolean, default: false, null: false
    add_column :leagues, :points_per_reception, :decimal, default: 0, null: false

    League.all.each do |league|
      if league.settings && !league.settings.empty?
        stat = league.settings["stat_modifiers"]["stats"]["stat"].detect{ |stat| stat["stat_id"] == "11" }
        league.points_per_reception = (stat && stat["value"]) || 0
      end

      league.sync_started_at = league.sync_finished_at
      league.has_finished_draft = league.draft_picks.any?
      league.save!
    end

    User.all.each do |user|
      user.sync_started_at = user.sync_finished_at
      user.save!
    end
  end
end
