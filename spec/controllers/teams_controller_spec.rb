require 'spec_helper'

describe TeamsController do

  describe "GET 'index'" do
    xit "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "PATCH 'refresh'" do
    it "refreshes teams for the user" do
      service_stub = double
      current_user = create(:user)
      session[:current_user_id] = current_user.id
      expect(YahooService).to receive(:new).with(current_user).and_return(service_stub)
      expect(service_stub).to receive(:refresh_teams)

      patch :refresh
    end
  end

end
