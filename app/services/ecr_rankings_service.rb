require 'csv'

class EcrRankingsService
  def standard_draft_report(file)
    EcrReport.new(file)
  end

  def ppr_draft_report(file)
    EcrReport.new(file)
  end

  def half_ppr_draft_report(file)
    EcrReport.new(file)
  end

  def sync_standard_draft_rankings(game, file)
    store_report(standard_draft_report(file), period: "draft",
                                              ranking_type: "standard",
                                              game: game)
  end

  def sync_ppr_draft_rankings(game, file)
    store_report(ppr_draft_report(file), period: "draft",
                                         ranking_type: "ppr",
                                         game: game)
  end

  def sync_half_ppr_draft_rankings(game, file)
    store_report(half_ppr_draft_report(file), period: "draft",
                                              ranking_type: "half_ppr",
                                              game: game)
  end

  protected

  def store_report(ecr_report, period:, ranking_type:, game:)
    return if RankingReport.find_by(original: ecr_report.original)

    report = RankingReport.new title: ecr_report.title,
                               original: ecr_report.original,
                               period: period,
                               ranking_type: ranking_type,
                               game: game

    ActiveRecord::Base.transaction do
      report.save!

      # Bulk create/fetch ranking profiles
      player_names = ecr_report.rankings.map(&:player_name)
      profile_attrs = player_names.map { |name| {name: name, game_id: game.id} }

      RankingProfile.upsert_all(
        profile_attrs,
        unique_by: [:game_id, :name],
        returning: [:id, :name]
      )

      profiles_by_name = RankingProfile.where(name: player_names, game: game)
                                     .index_by(&:name)

      # Prepare rankings data with profile ids
      rankings_data = ecr_report.rankings.map do |ecr_ranking|
        profile = profiles_by_name[ecr_ranking.player_name]
        {
          rank: ecr_ranking.rk,
          position: ecr_ranking.pos,
          team: ecr_ranking.team,
          bye_week: ecr_ranking.bye_week,
          ranking_report_id: report.id,
          ranking_profile_id: profile.id,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      # Bulk upsert rankings
      Ranking.upsert_all(
        rankings_data,
        unique_by: [:ranking_profile_id, :ranking_report_id]
      )
    end
  end


  def get(url)
    self.class.get(url).body
  end

  class EcrReport
    attr_reader :original

    def initialize(original)
      @original = original
      @doc = CSV.parse(original).drop(1).reject{|row| row.size <= 1}
    end

    def title
      Time.now.to_s
    end

    def rankings
      @doc
        .map { |draft_ranking| EcrRanking.new(draft_ranking) }
    end
  end

  class EcrRanking
    HEADERS = ["RK",
               "TIERS",
               "PLAYER NAME",
               "TEAM",
               "POS",
               "BYE WEEK"]

    HEADERS.each.with_index do |header, i|
      define_method header.downcase.split(" ").join("_") do
        @row[i]
      end
    end

    def initialize(row)
      @row = row
    end

    
  end
end