class Team < ActiveRecord::Base
  has_many :managers, autosave: true

  validates :yahoo_team_key, presence: true, uniqueness: true
end
