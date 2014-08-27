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
end
