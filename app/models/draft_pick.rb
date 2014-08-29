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

  def yahoo_info
    YahooRankingInfo.new(self)
  end

  def ecr_standard_info
    EcrRankingInfo.new(self, "standard")
  end

  def ecr_ppr_info
    EcrRankingInfo.new(self, "ppr")
  end

  class InfoBase
    attr_reader :draft_pick

    def name
      @draft_pick.player.full_name
    end

    def actual_pick
      pick
    end

    def vs_pick
      drafted_player && rank_value && pick - rank_value.to_i
    end

    def position
      @draft_pick.player.display_position
    end

    def team_abbr
      @draft_pick.player.editorial_team_abbr
    end

    protected

    def drafted_player
      @draft_pick.drafted_player
    end

    def pick
      @draft_pick.pick
    end
  end

  class YahooRankingInfo < InfoBase
    def initialize(draft_pick)
      @draft_pick = draft_pick
    end

    def rank_value
      @draft_pick.player.draft_average_pick
    end
  end

  class EcrRankingInfo < InfoBase
    def initialize(draft_pick, ranking_type)
      @draft_pick = draft_pick
      @ranking_type = ranking_type
    end

    def rank_value
      ranking.try(:rank)
    end

    protected

    def ranking
      @ranking ||= _ranking
    end

    def _ranking
      ranking_profile = drafted_player.try(:ranking_profile)
      return unless ranking_profile

      report = @draft_pick
                 .league
                 .game
                   .ranking_reports
                     .where(ranking_type: @ranking_type,
                            period: "draft")
                     .most_recent

      return unless report
      report
        .rankings
        .where(ranking_profile_id: ranking_profile)
        .first
    end
  end
end

