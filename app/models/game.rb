class Game < ActiveRecord::Base
  has_many :players
  has_many :ranking_profiles
  has_many :ranking_reports
  has_many :leagues

  scope :by_season, -> { order(season: :desc) }

  def self.most_recent
    by_season.first!
  end
end
