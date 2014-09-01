require 'rails_helper'

describe League do
  let(:league) { build(:league) }

  describe ".interesting" do
    let!(:synced_league) { create(:league, synced_at: 3.hours.ago) }
    let!(:undrafted_league) { create(:league, synced_at: 3.hours.ago) }
    let!(:auction_draft_league) { create(:league, is_auction_draft: true, synced_at: 3.hours.ago) }

    before do
      [synced_league, auction_draft_league].each do |league|
        create(:draft_pick, league: league)
      end
    end
    it "has synced leagues" do
      expect(League.interesting).to include(synced_league)
    end

    it "does not have auction draft leagues" do
      expect(League.interesting).to_not include(auction_draft_league)
    end

    it "does not have undrafted leagues" do
      expect(League.interesting).to_not include(undrafted_league)
    end
  end

  describe "#ppr?" do
    it "is true when the stat is there" do
      league.settings = {
        "stat_modifiers" => {
          "stats" => {
            "stat" => [
              { "stat_id" => "11", "value" => "1" }
            ]
          }
        }
      }

      expect(league.ppr?).to be true
    end

    it "is false when the stat is 0" do
      league.settings = {
        "stat_modifiers" => {
          "stats" => {
            "stat" => [
              { "stat_id" => "11", "value" => "0" }
            ]
          }
        }
      }

      expect(league.ppr?).to be false
    end

    it "is false when the stat is not there" do
      league.settings = {
        "stat_modifiers" => {
          "stats" => {
            "stat" => []
          }
        }
      }

      expect(league.ppr?).to be false
    end

    it "is false when the settings are not there" do
      league.settings = {}

      expect(league.ppr?).to be false
    end

    it "is false when the settings are nil" do
      league.settings = nil

      expect(league.ppr?).to be false
    end
  end
end
