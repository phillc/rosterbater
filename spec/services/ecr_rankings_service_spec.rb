require "rails_helper"

describe "EcrRankingsService" do
  let(:service) { EcrRankingsService.new }
  let(:game) { create(:game) }
  let(:standard_rankings) { fixture("get_standard_draft_rankings.csv") }

  describe "standard draft rankings" do

    describe "#standard_draft_report" do
      let(:report) { service.standard_draft_report(standard_rankings) }

      it "returns the count of rankings" do
        expect(report.rankings.size).to eq 371
      end

      it "returns the title" do
        expect(report.title).to_not eq nil
      end

      it "has the rank" do
        expect(report.rankings.first.rank).to eq "1"
        expect(report.rankings.last.rank).to eq "371"
      end
    end

    describe "#sync_standard_draft_rankings" do
      it "creates a report" do
        expect {
          service.sync_standard_draft_rankings(game, standard_rankings)
        }.to change{ RankingReport.count }.by(1)
      end

      it "saves the rankings" do
        expect {
          service.sync_standard_draft_rankings(game, standard_rankings)
        }.to change{ Ranking.count }.by(371)
      end

      it "does not duplicate reports" do
        service.sync_standard_draft_rankings(game, standard_rankings)

        expect {
          service.sync_standard_draft_rankings(game, standard_rankings)
        }.to change{ RankingReport.count }.by(0)
      end

      it "does not duplicate rankings" do
        service.sync_standard_draft_rankings(game, standard_rankings)

        expect {
          service.sync_standard_draft_rankings(game, standard_rankings)
        }.to change{ Ranking.count }.by(0)
      end

      it "flags the report as standard" do
        service.sync_standard_draft_rankings(game, standard_rankings)

        expect(RankingReport.last.ranking_type).to eq "standard"
      end

      it "flags the report as draft" do
        service.sync_standard_draft_rankings(game, standard_rankings)

        expect(RankingReport.last.period).to eq "draft"
      end

      it "stores the attributes" do
        service.sync_standard_draft_rankings(game, standard_rankings)

        ranking = Ranking.find_by(rank: "1")

        expect(ranking.rank).to eq 1
        expect(ranking.ranking_profile.name).to eq "David Johnson"
        expect(ranking.position).to eq "RB1"
        expect(ranking.team).to eq "ARI"
        expect(ranking.bye_week).to eq 8
        expect(ranking.best_rank).to eq "1"
        expect(ranking.worst_rank).to eq "2"
        expect(ranking.ave_rank).to eq "1.2"
        expect(ranking.std_dev).to eq "0.4"
        expect(ranking.adp).to eq "1.0"
      end
    end
  end

  describe "ppr draft rankings" do
    let(:ppr_rankings) { fixture("get_ppr_draft_rankings.csv") }

    describe "#sync_ppr_draft_rankings" do
      it "saves the rankings" do
        expect {
          service.sync_ppr_draft_rankings(game, ppr_rankings)
        }.to change{ Ranking.count }.by(376)
      end
    end
  end

  describe "0.5 draft rankings" do
    let(:half_ppr_rankings) { fixture("get_ppr_draft_rankings.csv") }

    describe "#sync_half_ppr_draft_rankings" do
      it "saves the rankings" do
        expect(RankingReport.where(ranking_type: "half_ppr").count).to eq 0
        expect {
          service.sync_half_ppr_draft_rankings(game, half_ppr_rankings)
        }.to change{ Ranking.count }.by(376)
        expect(RankingReport.where(ranking_type: "half_ppr").count).to eq 1
      end
    end
  end
end
