require 'rails_helper'

describe League do
  let(:league) { build(:league) }

  describe ".interesting_draft" do
    let!(:synced_league) { create(:league, :synced) }
    let!(:undrafted_league) { create(:league, :synced) }
    let!(:auction_draft_league) { create(:league, :synced, is_auction_draft: true) }

    before do
      [synced_league, auction_draft_league].each do |league|
        create(:draft_pick, league: league)
      end
    end
    it "has synced leagues" do
      expect(League.interesting_draft).to include(synced_league)
    end

    it "does not have undrafted leagues" do
      expect(League.interesting_draft).to_not include(undrafted_league)
    end
  end

  describe "#past_leagues" do
    it "lists pasts leagues" do
      league.renew = "314_31580"
      old_league = create(:league, yahoo_league_key: "314.l.31580", renew: "273_592842")
      older_league = create(:league, yahoo_league_key: "273.l.592842", renew: nil)

      expect(league.past_leagues).to eq [old_league, older_league]
    end

    it "survives dead pointer" do
      league.renew = "314_31580"
      old_league = create(:league, yahoo_league_key: "314.l.31580", renew: "lalalalala")

      expect(league.past_leagues).to eq [old_league]
    end
  end

  describe "#weeks_remaining" do
    it "is how many games are left" do
      league.playoff_start_week = 14
      league.current_week = 12

      expect(league.weeks_remaining).to eq 2
    end
  end

  describe "#currently_syncing?" do
    before do
      league.sync_started_at = nil
      league.sync_finished_at = nil
    end

    it "is false if haven't started syncing" do
      expect(league.currently_syncing?).to be false
    end

    it "is false if over a minute ago" do
      league.sync_started_at = 3.minutes.ago

      expect(league.currently_syncing?).to be false
    end

    it "is true if started recently" do
      league.sync_started_at = 3.seconds.ago

      expect(league.currently_syncing?).to be true
    end

    it "is false if finished" do
      league.sync_started_at = 10.seconds.ago
      league.sync_finished_at = 2.seconds.ago

      expect(league.currently_syncing?).to be false
    end

    it "is true if finished from before" do
      league.sync_started_at = 10.seconds.ago
      league.sync_finished_at = 12.seconds.ago

      expect(league.currently_syncing?).to be true
    end
  end
end
