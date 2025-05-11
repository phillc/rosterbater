class Player < ActiveRecord::Base
  belongs_to :game
  has_one :ranking_profile, foreign_key: "yahoo_player_key", primary_key: "yahoo_player_key"

  class NullPlayer
    attr_reader :yahoo_player_key

    def initialize(yahoo_player_key)
      @yahoo_player_key = yahoo_player_key
    end

    def full_name
      "Unknown player #{yahoo_player_key}"
    end

    def display_position
      "NA"
    end

    def draft_average_pick
      "NA"
    end

    def editorial_team_abbr
      "NA"
    end
  end

  validates :yahoo_player_key,
            :yahoo_player_id,
            :game, presence: true

end
