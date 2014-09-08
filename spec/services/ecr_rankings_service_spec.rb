require "rails_helper"

describe "EcrRankingsService" do
  let(:service) { EcrRankingsService.new }
  let(:game) { create(:game) }

  describe "standard draft rankings" do
    before do
      expect(service).to receive(:get)
                           .and_return(fixture("get_standard_draft_rankings.xls"))
                           .at_least(:once)
    end

    describe "#standard_draft_report" do
      let(:report) { service.standard_draft_report }

      it "returns the count of rankings" do
        expect(report.rankings.size).to eq 310
      end

      it "returns the title" do
        expect(report.title).to eq "2014 Preseason - Overall Rankings"
      end

      it "has the rank" do
        expect(report.rankings.first.rank).to eq "1"
        expect(report.rankings.last.rank).to eq "310"
      end
    end

    describe "#sync_standard_draft_rankings" do
      it "creates a report" do
        expect {
          service.sync_standard_draft_rankings(game)
        }.to change{ RankingReport.count }.by(1)
      end

      it "saves the rankings" do
        expect {
          service.sync_standard_draft_rankings(game)
        }.to change{ Ranking.count }.by(310)
      end

      it "does not duplicate reports" do
        service.sync_standard_draft_rankings(game)

        expect {
          service.sync_standard_draft_rankings(game)
        }.to change{ RankingReport.count }.by(0)
      end

      it "does not duplicate rankings" do
        service.sync_standard_draft_rankings(game)

        expect {
          service.sync_standard_draft_rankings(game)
        }.to change{ Ranking.count }.by(0)
      end

      it "flags the report as standard" do
        service.sync_standard_draft_rankings(game)

        expect(RankingReport.last.ranking_type).to eq "standard"
      end

      it "flags the report as draft" do
        service.sync_standard_draft_rankings(game)

        expect(RankingReport.last.period).to eq "draft"
      end

      it "stores the attributes" do
        service.sync_standard_draft_rankings(game)

        ranking = Ranking.find_by(rank: "1")

        expect(ranking.rank).to eq 1
        expect(ranking.ranking_profile.name).to eq "LeSean McCoy"
        expect(ranking.position).to eq "RB"
        expect(ranking.team).to eq "PHI"
        expect(ranking.bye_week).to eq 7
        expect(ranking.best_rank).to eq "1"
        expect(ranking.worst_rank).to eq "5"
        expect(ranking.ave_rank).to eq "1.74"
        expect(ranking.std_dev).to eq "0.86740993768806"
        expect(ranking.adp).to eq "1"
      end
    end
  end

  describe "ppr draft rankings" do
    before do
      expect(service).to receive(:get)
                           .and_return(fixture("get_ppr_draft_rankings.xls"))
                           .at_least(:once)
    end

    describe "#sync_ppr_draft_rankings" do
      it "saves the rankings" do
        expect {
          service.sync_ppr_draft_rankings(game)
        }.to change{ Ranking.count }.by(292)
      end
    end
  end

  describe "0.5 draft rankings" do
    before do
      expect(service).to receive(:get)
                           .and_return(fixture("get_ppr_draft_rankings.xls"))
                           .at_least(:once)
    end

    describe "#sync_half_ppr_draft_rankings" do
      it "saves the rankings" do
        expect(RankingReport.where(ranking_type: "half_ppr").count).to eq 0
        expect {
          service.sync_half_ppr_draft_rankings(game)
        }.to change{ Ranking.count }.by(292)
        expect(RankingReport.where(ranking_type: "half_ppr").count).to eq 1
      end
    end
  end
end
