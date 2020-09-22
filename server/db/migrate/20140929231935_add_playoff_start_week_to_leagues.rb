class AddPlayoffStartWeekToLeagues < ActiveRecord::Migration[4.2]
  class League < ActiveRecord::Base; end

  def change
    add_column :leagues, :playoff_start_week, :integer

    League.all.each do |league|
      if league.settings && !league.settings.empty?
        league.playoff_start_week = league.settings["playoff_start_week"]
        league.save!
      end
    end
  end
end
