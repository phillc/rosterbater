require 'rails_helper'

describe League do
  let(:league) { build(:league) }

  describe ".interesting" do
    let!(:synced_league) { create(:league, :synced) }
    let!(:undrafted_league) { create(:league, :synced) }
    let!(:auction_draft_league) { create(:league, :synced, is_auction_draft: true) }

    before do
      [synced_league, auction_draft_league].each do |league|
        create(:draft_pick, league: league)
      end
    end
    it "has synced leagues" do
      expect(League.interesting).to include(synced_league)
    end

    it "does not have undrafted leagues" do
      expect(League.interesting).to_not include(undrafted_league)
    end
  end
end
