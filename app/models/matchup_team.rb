class MatchupTeam < ActiveRecord::Base
  belongs_to :matchup
  belongs_to :team, foreign_key: "yahoo_team_key", primary_key: "yahoo_team_key"

  def opponent_matchup_team
    matchup
      .matchup_teams
      .detect{ |matchup_team| matchup_team.yahoo_team_key != yahoo_team_key }
  end
end
