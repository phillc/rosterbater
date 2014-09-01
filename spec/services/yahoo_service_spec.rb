require "rails_helper"

describe "YahooService" do
  let(:user) { create(:user) }
  let(:service) { YahooService.new(user) }

  describe "#get" do
    let(:good_response) { double("response", body: fixture("get_yahoo_games.xml")) }
    let(:good_token) { double("token", get: good_response) }
    let(:expired_token) { double("token") }
    let(:consumer_key_unknown_token) { double("token") }

    before do
      allow(expired_token).to receive(:get).and_raise(OAuth::Problem.new("token_expired"))
      allow(consumer_key_unknown_token).to receive(:get).and_raise(OAuth::Problem.new("consumer_key_unknown"))
    end

    it "returns results" do
      expect(service).to receive(:token).and_return(good_token).once
      expect(service.get("foo")).to be_a_kind_of(Nokogiri::XML::Document)
    end

    it "refreshed and retries for a token_expired" do
      expect(service).to receive(:token).and_return(expired_token, good_token).twice
      expect(service).to receive(:refresh_token!)

      expect(service.get("foo")).to be_a_kind_of(Nokogiri::XML::Document)
    end

    it "retries twice for a consumer_key_unknown" do
      expect(service).to receive(:token)
                           .and_return(consumer_key_unknown_token, consumer_key_unknown_token, good_token)
                           .exactly(3).times

      expect(service.get("foo")).to be_a_kind_of(Nokogiri::XML::Document)
    end

    it "blows up on three failures" do
      expect(service).to receive(:token)
                           .and_return(consumer_key_unknown_token, consumer_key_unknown_token, consumer_key_unknown_token)
                           .exactly(3).times

      expect{ service.get("foo") }.to raise_error(OAuth::Problem)
    end
  end

  describe "games" do
    let(:response) { double("response", body: fixture("get_yahoo_games.xml")) }
    let(:token) { double("token", get: response) }

    before do
      expect(service).to receive(:token).and_return(token).at_least(:once)
    end

    describe "#games" do
      it "returns the count" do
        expect(service.games.size).to eq 3
      end
    end

    describe "#sync_games" do
      it "saves the games" do
        expect {
          service.sync_games
        }.to change{ Game.count }.by(3)
      end

      it "does not duplicate" do
        service.sync_games

        expect {
          service.sync_games
        }.to change{ Game.count }.by(0)
      end

      it "stores the attributes" do
        service.sync_games

        game = Game.find_by(season: "2013")

        expect(game.yahoo_game_key).to eq 314
        expect(game.yahoo_game_id).to eq 314
        expect(game.name).to eq "Football"
        expect(game.code).to eq "nfl"
        expect(game.game_type).to eq "full"
        expect(game.url).to eq "http://football.fantasysports.yahoo.com/f1"
      end
    end
  end

  describe "players" do
    let(:game) { create(:game) }
    let(:league) { create(:league, game: game) }
    let(:response) { double("response") }
    let(:token) { double("token", get: response) }

    before do
      expect(service).to receive(:token).and_return(token).at_least(:once)
    end

    describe "#players" do
      it "goes through the pages" do
        expect(response).to receive(:body)
                              .and_return fixture("get_yahoo_game_players_1.xml"),
                                          fixture("get_yahoo_game_players_2.xml"),
                                          fixture("get_yahoo_game_players_3.xml")
        expect(service.players(game).to_a.size).to eq 74
      end

      it "retains the player attributes" do
        expect(response).to receive(:body)
                              .and_return fixture("get_yahoo_game_players_1.xml")
        player = service.players(game).first
        expect(player.player_key).to eq "314.p.8261"
        expect(player.player_id).to eq "8261"
        expect(player.full_name).to eq "Adrian Peterson"
        expect(player.first_name).to eq "Adrian"
        expect(player.last_name).to eq "Peterson"
        expect(player.ascii_first_name).to eq "Adrian"
        expect(player.ascii_last_name).to eq "Peterson"
        expect(player.status).to eq "O"
        expect(player.editorial_player_key).to eq "nfl.p.8261"
        expect(player.editorial_team_key).to eq "nfl.t.16"
        expect(player.editorial_team_full_name).to eq "Minnesota Vikings"
        expect(player.editorial_team_abbr).to eq "Min"
        expect(player.bye_weeks).to eq ["5"]
        expect(player.uniform_number).to eq "28"
        expect(player.display_position).to eq "RB"
        expect(player.image_url).to eq "http://l.yimg.com/iu/api/res/1.2/7gLeB7TR77HalMeJv.iDVA--/YXBwaWQ9eXZpZGVvO2NoPTg2MDtjcj0xO2N3PTY1OTtkeD0xO2R5PTE7Zmk9dWxjcm9wO2g9NjA7cT0xMDA7dz00Ng--/http://l.yimg.com/j/assets/i/us/sp/v/nfl/players_l/20120913/8261.jpg"
        expect(player.is_undroppable).to eq false
        expect(player.position_type).to eq "O"
        expect(player.eligible_positions).to eq ["RB"]
        expect(player.has_player_notes).to eq true
        expect(player.draft_average_pick).to eq "1.1"
        expect(player.draft_average_round).to eq "1.0"
        expect(player.draft_average_cost).to eq "72.6"
        expect(player.draft_percent_drafted).to eq "1.00"
      end
    end

    describe "#sync_game" do
      before do
        expect(response).to receive(:body)
                              .and_return fixture("get_yahoo_game_players_1.xml"),
                                          fixture("get_yahoo_game_players_2.xml"),
                                          fixture("get_yahoo_game_players_3.xml")
      end

      it "saves the players" do
        expect {
          service.sync_game(game)
        }.to change{ game.players.count }.by(74)
      end

      it "does not duplicate" do
        service.sync_game(game)

        expect(response).to receive(:body)
                              .and_return fixture("get_yahoo_game_players_1.xml"),
                                          fixture("get_yahoo_game_players_2.xml"),
                                          fixture("get_yahoo_game_players_3.xml")

        expect {
          service.sync_game(game)
        }.to change{ Player.count }.by(0)
      end

      it "stores the attributes" do
        service.sync_game(game)

        player = game.players.find_by(yahoo_player_key: "314.p.8261")

        expect(player.yahoo_player_key).to eq "314.p.8261"
        expect(player.yahoo_player_id).to eq "8261"
        expect(player.full_name).to eq "Adrian Peterson"
        expect(player.first_name).to eq "Adrian"
        expect(player.last_name).to eq "Peterson"
        expect(player.ascii_first_name).to eq "Adrian"
        expect(player.ascii_last_name).to eq "Peterson"
        expect(player.status).to eq "O"
        expect(player.editorial_player_key).to eq "nfl.p.8261"
        expect(player.editorial_team_key).to eq "nfl.t.16"
        expect(player.editorial_team_full_name).to eq "Minnesota Vikings"
        expect(player.editorial_team_abbr).to eq "Min"
        expect(player.bye_weeks).to eq ["5"]
        expect(player.uniform_number).to eq "28"
        expect(player.display_position).to eq "RB"
        expect(player.image_url).to eq "http://l.yimg.com/iu/api/res/1.2/7gLeB7TR77HalMeJv.iDVA--/YXBwaWQ9eXZpZGVvO2NoPTg2MDtjcj0xO2N3PTY1OTtkeD0xO2R5PTE7Zmk9dWxjcm9wO2g9NjA7cT0xMDA7dz00Ng--/http://l.yimg.com/j/assets/i/us/sp/v/nfl/players_l/20120913/8261.jpg"
        expect(player.is_undroppable).to eq false
        expect(player.position_type).to eq "O"
        expect(player.eligible_positions).to eq ["RB"]
        expect(player.has_player_notes).to eq true
        expect(player.draft_average_pick).to eq "1.1"
        expect(player.draft_average_round).to eq "1.0"
        expect(player.draft_average_cost).to eq "72.6"
        expect(player.draft_percent_drafted).to eq "1.00"
      end
    end
  end

  describe "user leagues" do
    let(:response) { double("response", body: fixture("get_yahoo_user_leagues.xml")) }
    let(:token) { double("token", get: response) }
    let!(:game) { create(:game) }

    before do
      expect(service).to receive(:token).and_return(token).at_least(:once)
    end

    describe "#leagues" do
      it "returns the count" do
        expect(service.leagues(game).size).to eq 3
      end

      it "retains the attributes" do
        league = service.leagues(game).first

        expect(league.name).to eq "Stay Thirsty My Friends"
        expect(league.league_key).to eq "331.l.6781"
        expect(league.league_id).to eq "6781"
        expect(league.url).to eq "http://football.fantasysports.yahoo.com/f1/6781"
        expect(league.num_teams).to eq "12"
        expect(league.scoring_type).to eq "head"
        expect(league.renew).to eq "314_31580"
        expect(league.renewed).to be_nil
        expect(league.current_week).to eq "1"
        expect(league.start_week).to eq "1"
        expect(league.end_week).to eq "16"
        expect(league.start_date).to eq "2014-09-04"
        expect(league.end_date).to eq "2014-12-22"
      end
    end

    describe "#sync_leagues" do
      it "saves the leagues" do
        expect {
          service.sync_leagues(game)
        }.to change{ League.count }.by(3)
      end

      it "returns the leagues" do
        expect(service.sync_leagues(game).size).to eq 3
      end

      it "associates" do
        service.sync_leagues(game).each do |league|
          expect(league.users).to include(user)
          expect(league.game).to eq game
        end
      end

      it "assigns synced_at" do
        expect(user.reload.synced_at).to be nil
        service.sync_leagues(game)
        expect(user.reload.synced_at).to_not be nil
      end

      it "does not duplicate" do
        service.sync_leagues(game)

        expect {
          service.sync_leagues(game)
        }.to change{ League.count }.by(0)
      end

      it "stores the attributes" do
        service.sync_leagues(game)

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
      allow(service).to receive(:token).and_return(token)
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
      it "returns the count" do
        expect(league_details.draft_results.size).to eq 210
      end

      it "retains the attributes" do
        result = league_details.draft_results.first
        expect(result.pick).to eq "1"
        expect(result.round).to eq "1"
        expect(result.team_key).to eq "314.l.31580.t.6"
        expect(result.player_key).to eq "314.p.8261"
      end
    end

    describe "#sync_league" do
      before do
        expect(service).to receive(:sync_league_details).at_least(:once) # slow
      end

      it "assigns synced_at" do
        expect(league.reload.synced_at).to be nil
        service.sync_league(league)
        expect(league.reload.synced_at).to_not be nil
      end
    end

    describe "#sync_league_details" do
      describe "teams" do
        before do
          expect(service).to receive(:sync_league_draft_results).at_least(:once) # slow
        end

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

      describe "draft results" do
        it "saves the picks" do
          expect {
            service.sync_league_details(league)
          }.to change{ league.draft_picks.count }.by(210)
        end

        it "does not duplicate" do
          service.sync_league_details(league)

          expect {
            service.sync_league_details(league)
          }.to change{ DraftPick.count }.by(0)
        end

        it "stores the attributes" do
          service.sync_league_details(league)

          pick = league.draft_picks.where(pick: 1).first
          expect(pick.round).to eq 1
          expect(pick.yahoo_team_key).to eq "314.l.31580.t.6"
          expect(pick.yahoo_player_key).to eq "314.p.8261"
        end
      end

      describe "settings" do
        before do
          expect(service).to receive(:sync_league_teams).at_least(:once) # slow
          expect(service).to receive(:sync_league_draft_results).at_least(:once) # slow
        end

        it "stores settings" do
          service.sync_league_details(league)
          expect(league.is_auction_draft).to eq false
          expect(league.trade_end_date).to eq Date.parse("2013-11-15")
          expect(league.settings).to include({"draft_type" => "live", "max_teams" => "14"})
        end
      end
    end
  end

end
