class Game < ActiveRecord::Base
  has_many :players
  has_many :ranking_profiles
  has_many :ranking_reports

  def self.most_recent
    order(season: :desc).first!
  end
end
