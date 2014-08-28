class DraftPick < ActiveRecord::Base
  belongs_to :league
  belongs_to :team, foreign_key: "yahoo_team_key", primary_key: "yahoo_team_key"
  belongs_to :drafted_player, class_name: "Player", foreign_key: "yahoo_player_key", primary_key: "yahoo_player_key"

  validates :team,
            :pick,
            :round,
            :yahoo_team_key,
            :yahoo_player_key, presence: true

  def player
    drafted_player || Player::NullPlayer.new(yahoo_player_key)
  end

  def vs_yahoo_ranking
    drafted_player && pick - drafted_player.draft_average_pick.to_i
  end
end

