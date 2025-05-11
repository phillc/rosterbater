class RankingReport < ActiveRecord::Base
  belongs_to :game
  has_many :rankings, autosave: true

  def self.most_recent
    order(updated_at: :desc).first
  end
end
