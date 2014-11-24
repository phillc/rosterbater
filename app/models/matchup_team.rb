class MatchupTeam < ActiveRecord::Base
  belongs_to :team, foreign_key: "yahoo_team_key", primary_key: "yahoo_team_key"
end
