class RankingProfile < ActiveRecord::Base
  belongs_to :game
  belongs_to :player, class_name: "Player", foreign_key: "yahoo_player_key", primary_key: "yahoo_player_key"
  has_many :rankings

  scope :unlinked, ->{ where(yahoo_player_key: nil) }

  def link
    mappings = {
      "Timothy" => "Tim"
    }
    if player = game.players.find_by(full_name: name)
      update(player: player)
    elsif rankings.map(&:position).include?("DST")
      player = game.players.find_by(display_position: "DEF", editorial_team_full_name: name)
      update(player: player) if player
    else
      first_name, last_name = name.split(" ")
      if mappings.keys.include?(first_name)
        player = game.players.find_by(full_name: [mappings[first_name], last_name].join(" "))
      end
      if !player
        clean = ->(val){ "trim(both ' ' from
                            regexp_replace(lower(#{val}), '(\\.|jr)', '', 'g')
                          )" }
        player = game.players.where("#{clean.("full_name")} = #{clean.("?")}", name).first
      end

      update(player: player) if player
    end
  end
end
