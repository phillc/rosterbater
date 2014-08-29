class EcrRankingsService
  include HTTParty
  base_uri "http://www.fantasypros.com/nfl/rankings"

  def get_standard_draft_rankings
    get "/consensus-cheatsheets.php?export=xls"
  end

  def get_ppr_draft_rankings
    get "/ppr-cheatsheets.php?export=xls"
  end

  def get_half_draft_rankings
    get "/half-point-ppr-cheatsheets.php?export=xls"
  end

  def standard_draft_report
    EcrReport.new(get_standard_draft_rankings)
  end

  def ppr_draft_report
    EcrReport.new(get_ppr_draft_rankings)
  end

  def sync_standard_draft_rankings(game)
    store_report(standard_draft_report, period: "draft",
                                        ranking_type: "standard",
                                        game: game)
  end

  def sync_ppr_draft_rankings(game)
    store_report(ppr_draft_report, period: "draft",
                                   ranking_type: "ppr",
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

    ecr_report.rankings.each do |ecr_ranking|
      ranking = report.rankings.build
      ranking.ranking_profile = RankingProfile
                                  .where(name: ecr_ranking.player_name,
                                         game: game)
                                  .first_or_create!
      ecr_ranking.update(ranking)
    end

    report.save!
  end


  def get(url)
    self.class.get(url).body
  end

  class EcrReport
    attr_reader :original

    def initialize(original)
      @original = original
      @doc = CSV.parse(original, col_sep: "\t")
    end

    def title
      @doc[2].first.strip
    end

    def rankings
      @doc
        .drop(6)
        .map { |draft_ranking| EcrRanking.new(draft_ranking) }
    end
  end

  class EcrRanking
    HEADERS = ["Rank",
               "Player Name",
               "Position",
               "Team",
               "Bye Week",
               "Best Rank",
               "Worst Rank",
               "Ave Rank",
               "Std Dev",
               "ADP"]

    HEADERS.each.with_index do |header, i|
      define_method header.downcase.split(" ").join("_") do
        @row[i]
      end
    end

    def initialize(row)
      @row = row
    end

    def update(ranking)
      %w(
        rank
        position
        team
        bye_week
        best_rank
        worst_rank
        ave_rank
        std_dev
        adp
      ).each do |attribute|
        ranking.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end
end
