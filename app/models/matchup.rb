class Matchup < ActiveRecord::Base
  has_many :matchup_teams, autosave: true, dependent: :destroy

  def as_json(options={})
    json = super(only: [:id, :week, :status, :is_tied])
    json[:teams] = matchup_teams.map do |matchup_team|
      matchup_team.as_json(only: [:is_winner, :points, :projected_points], methods: [:name]).tap do |matchup_team_json|
        matchup_team_json[:id] = matchup_team.team.id
      end
    end
    json
  end
end
