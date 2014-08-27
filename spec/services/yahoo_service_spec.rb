require "rails_helper"

describe "YahooService" do
  let(:user) { create(:user) }
  let(:service) { YahooService.new(user) }

  # describe "#teams" do
  #   before do
  #     expect(service).to receive(:get).and_return(user_teams_response)
  #   end

  #   it "returns the count" do
  #     expect(service.teams.size).to eq 2
  #   end

  #   it "returns the team attributes" do
  #     team = service.teams.first
  #     expect(team.name).to eq("foo")
  #     expect(team.team_id).to eq("4")
  #   end
  # end

  # describe "#refresh_teams" do
  #   before do
  #     expect(service).to receive(:get)
  #                          .and_return(user_teams_response)
  #                          .at_least(1).times
  #   end

  #   it "saves the teams" do
  #     expect {
  #       service.refresh_teams
  #     }.to change(Team, :count).by(2)
  #   end

  #   it "saves the managers" do
  #     expect {
  #       service.refresh_teams
  #     }.to change(Manager, :count).by(2)
  #   end

  #   it "stores the attributes" do
  #     service.refresh_teams

  #     team = Team.find_by(yahoo_league_id: 111, yahoo_team_id: 4)
  #     expect(team.name).to eq("foo")
  #     expect(team.url).to eq("http://example.com")
  #     expect(team.yahoo_division_id).to eq(2)

  #     expect(team.managers.first.nickname).to eq("PC")
  #     expect(team.managers.first.yahoo_manager_id).to eq(4)
  #   end

  #   it "associates the current user" do
  #     service.refresh_teams

  #     team = Team.find_by(yahoo_league_id: 111, yahoo_team_id: 4)
  #     expect(team.managers.first.user).to eq(user)

  #   end

  #   it "does not duplicate" do
  #     service.refresh_teams

  #     expect {
  #       service.refresh_teams
  #     }.to change{Team.count + Manager.count}.by(0)
  #   end
  # end

  describe "user leagues" do
    let(:response) { double("response", body: fixture("get_yahoo_user_leagues.xml")) }
    let(:token) { double("token", get: response) }

    before do
      expect(service).to receive(:token).and_return(token).at_least(:once)
    end

    describe "#leagues" do
      it "returns the count" do
        expect(service.leagues.size).to eq 3
      end

      describe "attributes" do
        let(:league) { service.leagues.first }

        it "should have the league name" do
          expect(league.name).to eq "Stay Thirsty My Friends"
        end

        it "should have the league key" do
          expect(league.league_key).to eq "331.l.6781"
        end

        it "should have the league id" do
          expect(league.league_id).to eq "6781"
        end

        it "should have the url" do
          expect(league.url).to eq "http://football.fantasysports.yahoo.com/f1/6781"
        end

        it "should have the number of teams" do
          expect(league.num_teams).to eq "12"
        end

        it "should have the scoring type" do
          expect(league.scoring_type).to eq "head"
        end

        it "should have the renew" do
          expect(league.renew).to eq "314_31580"
        end

        it "should have the renewed" do
          expect(league.renewed).to be_nil
        end

        it "should have the current week" do
          expect(league.current_week).to eq "1"
        end

        it "should have the start week" do
          expect(league.start_week).to eq "1"
        end

        it "should have the end week" do
          expect(league.end_week).to eq "16"
        end

        it "should have the start date" do
          expect(league.start_date).to eq "2014-09-04"
        end

        it "should have the end date" do
          expect(league.end_date).to eq "2014-12-22"
        end
      end
    end

    describe "#refresh_leagues" do
      it "saves the leagues" do
        expect {
          service.refresh_leagues
        }.to change{ League.count }.by(3)
      end

      it "returns the leagues" do
        expect(service.refresh_leagues.size).to eq 3
      end

      it "associates the current user" do
        service.refresh_leagues.each do |league|
          expect(league.users).to include(user)
        end
      end

      it "does not duplicate" do
        service.refresh_leagues

        expect {
          service.refresh_leagues
        }.to change{ League.count }.by(0)
      end

      it "stores the attributes" do
        service.refresh_leagues

        league = League.find_by(yahoo_league_key: "314.l.31580")

        expect(league.name).to eq("Stay thirsty my friends")
        expect(league.yahoo_league_id).to eq(31580)
        expect(league.url).to eq("http://football.fantasysports.yahoo.com/archive/nfl/2013/31580")

        expect(league.num_teams).to eq 14
        expect(league.scoring_type).to eq "head"
        expect(league.renew).to eq "273_592842"
        expect(league.renewed).to eq "331_6781"
        expect(league.current_week).to eq 16
        expect(league.start_week).to eq 1
        expect(league.end_week).to eq 16
        expect(league.start_date).to eq Date.parse("2013-09-05")
        expect(league.end_date).to eq Date.parse("2013-12-23")
        expect(league.users).to include user
      end
    end
  end

  describe "league details" do
    let(:league) { create(:league) }
    let(:response) { double("response", body: fixture("get_yahoo_league_details.xml")) }
    let(:token) { double("token", get: response) }
    let(:league_details) { service.league_details(league) }

    before do
      expect(service).to receive(:token).and_return(token).at_least(:once)
    end

    describe "#teams" do
      it "returns the count" do
        expect(league_details.teams.size).to eq 14
      end

      it "retains the team attributes" do
        team = league_details.teams.first
        expect(team.name).to eq "Bacon"
        expect(team.team_key).to eq "314.l.31580.t.1"
        expect(team.team_id).to eq "1"
        expect(team.url).to eq "http://football.fantasysports.yahoo.com/archive/nfl/2013/31580/1"
        expect(team.logo_url).to eq "http://i.imgur-ysports.com/miBocdcy.png"
        expect(team.waiver_priority).to eq "7"
        expect(team.faab_balance).to eq "0"
        expect(team.number_of_moves).to eq "70"
        expect(team.number_of_trades).to eq "6"
        expect(team.managers.size).to eq 1
        expect(team.managers.first.name).to eq "Phillip"
        expect(team.managers.first.image_url).to eq "https://s.yimg.com/dh/ap/social/profile/profile_b64.png"
        expect(team.managers.first.is_commissioner).to eq true
        expect(team.managers.first.email).to_not be_empty
      end
    end

    describe "#draft_results" do
      it "shows them"
    end

    describe "#sync_league_details" do
      describe "teams" do
        it "saves the teams" do
          expect {
            service.sync_league_details(league)
          }.to change{ league.teams.count }.by(14)
        end

        it "does not duplicate" do
          service.sync_league_details(league)

          expect {
            service.sync_league_details(league)
          }.to change{ League.count }.by(0)
        end

        it "stores the attributes" do
          service.sync_league_details(league)

          team = league.teams.where(yahoo_team_id: 1).first
          expect(team.name).to eq "Bacon"
          expect(team.yahoo_team_key).to eq "314.l.31580.t.1"
          expect(team.yahoo_team_id).to eq 1
          expect(team.url).to eq "http://football.fantasysports.yahoo.com/archive/nfl/2013/31580/1"
          expect(team.logo_url).to eq "http://i.imgur-ysports.com/miBocdcy.png"
          expect(team.waiver_priority).to eq 7
          expect(team.faab_balance).to eq 0
          expect(team.number_of_moves).to eq 70
          expect(team.number_of_trades).to eq 6
          expect(team.managers.size).to eq 1
          expect(team.managers.first.name).to eq "Phillip"
          expect(team.managers.first.image_url).to eq "https://s.yimg.com/dh/ap/social/profile/profile_b64.png"
          expect(team.managers.first.is_commissioner).to eq true
          expect(team.managers.first.email).to_not be_empty
        end

        it "updates changes" do
          service.sync_league_details(league)

          team = league.teams.where(yahoo_team_id: 1).first
          team.update! name: "Not bacon"
          team.managers.first.update! name: "Someone"

          service.sync_league_details(league)

          expect(team.reload.name).to eq "Bacon"
          expect(team.managers.first.reload.name).to eq "Phillip"
        end

        it "deletes managers" do
          service.sync_league_details(league)

          team = league.teams.where(yahoo_team_id: 1).first
          team.managers.first.update! yahoo_guid: "wrong"

          service.sync_league_details(league)

          expect(team.managers.first.reload.yahoo_guid).to eq "JBAMN3TTXS5EN3SAWHYJKRRGNU"
        end
      end

      it "updates the draft results"
    end
  end

  describe "players" do
    let(:league) { create(:league) }
    let(:response) { double("response") }
    let(:token) { double("token", get: response) }

    before do
      expect(service).to receive(:token).and_return(token).at_least(:once)
      expect(response).to receive(:body)
                            .and_return fixture("get_yahoo_league_players_1.xml"),
                                        fixture("get_yahoo_league_players_2.xml"),
                                        fixture("get_yahoo_league_players_3.xml")
    end

    describe "#players" do
      it "goes through the pages" do
        expect(service.players(league).to_a.size).to eq 74
      end
    end
  end
end
