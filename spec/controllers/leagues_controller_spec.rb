require 'rails_helper'

describe LeaguesController do
  let(:user) { create(:user) }
  let(:league) { create(:league, users: [user]) }

  before do
    login_as(user)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show', id: league
      expect(response).to be_success
    end
  end

  describe "GET 'draft_board'" do
    it "has the picks sorted out" do
      create(:draft_pick, pick: 9, yahoo_team_key: "teamkey3", yahoo_player_key: "pick9", league: league)
      create(:draft_pick, pick: 8, yahoo_team_key: "teamkey2", yahoo_player_key: "pick8", league: league)
      create(:draft_pick, pick: 7, yahoo_team_key: "teamkey1", yahoo_player_key: "pick7", league: league)
      create(:draft_pick, pick: 6, yahoo_team_key: "teamkey1", yahoo_player_key: "pick6", league: league)
      create(:draft_pick, pick: 5, yahoo_team_key: "teamkey2", yahoo_player_key: "pick5", league: league)
      create(:draft_pick, pick: 4, yahoo_team_key: "teamkey3", yahoo_player_key: "pick4", league: league)
      create(:draft_pick, pick: 3, yahoo_team_key: "teamkey3", yahoo_player_key: "pick3", league: league)
      create(:draft_pick, pick: 2, yahoo_team_key: "teamkey2", yahoo_player_key: "pick2", league: league)
      create(:draft_pick, pick: 1, yahoo_team_key: "teamkey1", yahoo_player_key: "pick1", league: league)

      get 'draft_board', id: league

      expect(assigns(:picks).first).to eq ["teamkey1", ["pick1", "pick6", "pick7"]]
    end
  end
end
