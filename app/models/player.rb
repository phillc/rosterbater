class Player < ActiveRecord::Base
  belongs_to :game

  class NullPlayer
    attr_reader :yahoo_player_key

    def initialize(yahoo_player_key)
      @yahoo_player_key = yahoo_player_key
    end

    def full_name
      "Unknown player #{yahoo_player_key}"
    end
  end

  validates :yahoo_player_key,
            :yahoo_player_id,
            :game, presence: true

end
