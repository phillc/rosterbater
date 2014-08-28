require 'rails_helper'

describe DraftPick do
  describe "#vs_yahoo_ranking" do
    it "is negative when too early" do
      draft_pick = create(:draft_pick, pick: 1)
      create(:player, draft_average_pick: 2, yahoo_player_key: draft_pick.yahoo_player_key)

      expect(draft_pick.vs_yahoo_ranking).to eq -1
    end

    it "is 0 when on time" do
      draft_pick = create(:draft_pick, pick: 2)
      create(:player, draft_average_pick: 2, yahoo_player_key: draft_pick.yahoo_player_key)

      expect(draft_pick.vs_yahoo_ranking).to eq 0
    end

    it "is positive when late" do
      draft_pick = create(:draft_pick, pick: 3)
      create(:player, draft_average_pick: 2, yahoo_player_key: draft_pick.yahoo_player_key)

      expect(draft_pick.vs_yahoo_ranking).to eq 1
    end

    it "handles lack of player" do
      draft_pick = create(:draft_pick, pick: 3)

      expect(draft_pick.vs_yahoo_ranking).to eq nil
    end
  end
end
