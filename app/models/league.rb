class League < ActiveRecord::Base
  belongs_to :game
  has_many :teams
  has_many :draft_picks
  has_and_belongs_to_many :users

  validates :name,
            :game,
            :yahoo_league_key,
            :yahoo_league_id, presence: true

  def ppr?
    settings && settings["stat_modifiers"]["stats"]["stat"].detect{ |stat| stat["stat_id"] == "11" }["value"]
  end
end
