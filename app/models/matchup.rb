class Matchup < ActiveRecord::Base
  has_many :matchup_teams, autosave: true
end
