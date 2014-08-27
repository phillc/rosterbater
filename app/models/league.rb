class League < ActiveRecord::Base
  has_many :teams
  has_and_belongs_to_many :users

  validates :name,
            :yahoo_league_key,
            :yahoo_league_id, presence: true
end
